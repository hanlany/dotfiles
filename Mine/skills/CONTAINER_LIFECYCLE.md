# Docker Development Container Lifecycle

Use this pattern to provide small, single-purpose scripts for building,
creating, starting, and entering a `<project>` development container. Replace
`<project>` with the target repository's short, lowercase name. The container
is designed to remain alive independently of any terminal session.

This document is both a user guide and an implementation reference. An agent
adapting this pattern to another repository should follow the contracts in
[Agent implementation contract](#agent-implementation-contract).

## Reference implementation

The unchanged files under [`reference/container/`](reference/container/) are a
working implementation copied from OGBench. Use
[`build.sh`](reference/container/build.sh),
[`spawn.sh`](reference/container/spawn.sh),
[`run.sh`](reference/container/run.sh),
[`attach.sh`](reference/container/attach.sh), and
[`dev.dockerfile`](reference/container/dev.dockerfile) as implementation
references only. They still contain OGBench-specific names and paths; copy them
into the target repository and replace those values using
[Project-specific constants](#project-specific-constants) before use.

## Quick start

After adapting and placing the scripts in the target repository (for example,
under `local/dev`), run:

```bash
./build.sh    # Build or rebuild the image.
./spawn.sh    # Create and start the container once.
./attach.sh   # Open an interactive shell in the running container.
```

Exit an attached shell with `exit` or Ctrl-D. The container continues running.
If the container is later stopped, restart it with:

```bash
./run.sh
./attach.sh
```

## Lifecycle model

The Docker image and container are different objects:

```text
dev.dockerfile --build.sh--> image: <project>
                                  |
                               spawn.sh
                                  v
                         container: <project>_dev
                           |              |
                     stopped state   running state
                           |              |
                         run.sh        attach.sh
                           |              |
                           +------->------+---> temporary Bash session
```

| Container state | Command | Result |
| --- | --- | --- |
| Does not exist | `./spawn.sh` | Creates it in the background and leaves it running |
| Exists and is stopped | `./run.sh` | Starts the existing container |
| Exists and is running | `./attach.sh` | Opens a disposable interactive Bash session |
| Exists and is running | `./run.sh` | Reports that it is already running; no change |

Creating and starting are intentionally separate operations. Container options
such as mounts, GPU access, networking, and environment variables are fixed at
creation time. `docker start` cannot change them.

## Script roles

### `build.sh`: build the image

- Resolves paths relative to the script, so it is independent of the caller's
  current working directory.
- Uses the repository root as the Docker build context.
- Builds the selected Dockerfile (for example, `local/dev/dev.dockerfile`) as
  image `<project>`.
- Does not create, start, stop, or enter a container.

Rebuilding the image does not update an existing container. Recreate the
container when it must use a newly built image.

### `spawn.sh`: create and start the persistent container

- Refuses to continue if a container named `<project>_dev` already exists.
- Creates the host-side Bash history file before mounting it.
- Configures the workspace mount, working directory, host networking, optional
  X11 forwarding, and optional NVIDIA GPU access.
- Starts the container detached with `sleep infinity` as its long-lived primary
  process.
- Does not attach the user's terminal.

Because the primary process is not the user's shell, closing a terminal or
exiting an attached shell does not stop the container.

This project currently uses `--privileged` and `--network=host`. Both grant more
host access than an isolated container normally has; retain them in another
repository only when its workload requires them.

### `run.sh`: start an existing stopped container

- Fails with a useful message if `<project>_dev` has never been created.
- Is idempotent when the container is already running.
- Restores local X11 authorization when applicable.
- Warns when an SSH-forwarded `DISPLAY` differs from the value captured when
  the container was created.
- Does not create a container and does not open a shell.

An SSH X11 display is part of the container's creation-time environment. If it
changes between SSH sessions and GUI programs stop working, recreate the
container from the current login.

### Codex and bubblewrap namespace support

Codex starts sandboxed commands with bubblewrap. When Codex itself runs inside
the development container, bubblewrap must be able to create nested user and
mount namespaces. Docker's default seccomp/AppArmor policy and an incompatible
Docker user namespace can otherwise make Codex commands fail with errors such
as `Operation not permitted` while creating a namespace or mount.

`spawn.sh` MUST establish the fix when the container is created:

- Pre-create `${ws_root}/.git`, `${ws_root}/.agents`, and `${ws_root}/.codex`
  on the host before mounting `${ws_root}` at `/workspace`. These paths are
  Codex sandbox mount targets; creating them in advance prevents bubblewrap
  from trying to create them through a restricted workspace mount.
- Create the container with `--privileged` and `--userns=host`.
- Explicitly pass `--security-opt seccomp=unconfined` and
  `--security-opt apparmor=unconfined` so the host security profiles do not
  block bubblewrap's namespace and mount operations.
- Add `SYS_ADMIN` and `SYS_CHROOT`. These capabilities are required by the
  nested sandbox setup and also make that dependency visible if the broader
  privileged setting is later tightened.

All of those Docker options are creation-time configuration. `run.sh` MUST
start the existing container with `docker start`; it MUST NOT replace that with
a new `docker run`, nor claim that it can add missing namespace, security, or
capability options to an existing container. A container created without this
configuration must be stopped, removed, and recreated with `spawn.sh`:

```bash
docker stop <project>_dev
docker rm <project>_dev
./spawn.sh
```

Restarting a correctly created container with `run.sh` preserves the namespace
configuration. If `run.sh` is enhanced to validate it, a mismatch SHOULD cause
a clear error directing the user to recreate the container rather than silently
starting a container in which Codex sandbox commands will fail.

### `attach.sh`: open a disposable interactive shell

- Requires `<project>_dev` to be running.
- Runs `docker exec -it <project>_dev bash`.
- Replaces the host script process with the Docker CLI via shell `exec`.
- Does not attach to the container's primary process.

The last distinction is the key safety property. `docker attach` connects to a
container's primary process and can affect its lifetime or input stream.
`docker exec` creates a separate process, so exiting that Bash session leaves
the persistent container running.

## Common operations

Inspect status:

```bash
docker ps --filter name=<project>_dev
docker ps -a --filter name=<project>_dev
```

Stop the container without deleting it:

```bash
docker stop <project>_dev
```

Recreate it after changing image or creation-time settings:

```bash
docker stop <project>_dev
docker rm <project>_dev
./spawn.sh
```

Removing a container deletes changes made only in its writable container layer.
Files under the bind-mounted workspace and the mounted `bash_history` file are
stored on the host and survive removal.

## Agent implementation contract

When rebuilding this lifecycle for another repository, preserve these
behavioral requirements even if filenames or Docker options change.

### Required inputs to identify

1. Repository root and location of the Dockerfile.
2. Image name and globally unique container name.
3. Host workspace path, container workspace path, and working directory.
4. Required mounts, ports or host networking, devices, capabilities, and
   environment variables.
5. Whether GPU, GUI/X11, SSH forwarding, and persistent shell history are
   actually needed.
6. The interactive shell available in the image (`bash` or `sh`).

### Required behavior

- Every script MUST begin with `#!/usr/bin/env bash` and
  `set -euo pipefail`.
- Scripts that use repository paths MUST resolve them from
  `${BASH_SOURCE[0]}`, not from the caller's working directory.
- The build script MUST only build the image.
- The spawn script MUST refuse to overwrite an existing named container.
- The spawn script MUST run detached and use a long-lived, non-interactive
  primary command such as `sleep infinity`.
- The start script MUST distinguish missing, running, and stopped containers.
- The attach script MUST use `docker exec -it`; it MUST NOT use
  `docker attach`.
- Exiting a shell created by the attach script MUST leave the container running.
- Error messages SHOULD name the next appropriate lifecycle command.
- Creation-time configuration MUST remain in the spawn script. The start and
  attach scripts MUST NOT imply that they can alter that configuration.
- When Codex runs inside the container, the spawn script MUST pre-create its
  workspace mount targets and supply the namespace, security-policy, and
  capability options specified in
  [Codex and bubblewrap namespace support](#codex-and-bubblewrap-namespace-support).
- The start script MUST preserve that creation-time namespace configuration. If
  it validates the configuration and finds it incompatible, it SHOULD fail with
  instructions to remove and recreate the container with the spawn script.
- Scripts SHOULD quote all variable expansions and use a Bash array for Docker
  arguments.
- Optional features SHOULD be detected and should degrade with a clear message
  when unavailable.

### Adaptation procedure

1. Read the target Dockerfile and determine its shell and default command.
2. Choose image and container names; use the same constants in every script.
3. Implement the build script with the correct build context and Dockerfile.
4. Implement the spawn script with all creation-time options and a detached
   persistent command.
5. Implement the start script with explicit state checks.
6. Implement the attach script with an independent interactive exec session.
7. Make all scripts executable.
8. Validate syntax with `bash -n build.sh spawn.sh run.sh attach.sh`.
9. Test the full state sequence: missing, created/running, attached/exited,
   stopped, and restarted.

### Acceptance checklist

- `spawn.sh` leaves a running container after its own process exits.
- A second `spawn.sh` invocation fails without replacing the container.
- Exiting `attach.sh` does not stop the container.
- `run.sh` starts a stopped container and safely handles an already-running one.
- `attach.sh` reports a clear error for a missing or stopped container.
- Host-mounted project changes are visible inside the container.
- Required GPU and GUI behavior works, or the scripts clearly report why it is
  unavailable.
- Codex can run a sandboxed command inside both a newly spawned container and a
  stopped container restarted by `run.sh`, without a bubblewrap namespace or
  mount-permission error.
- Rebuilding the image and explicitly recreating the container uses the new
  image.

## Project-specific constants

Use this table to choose consistent target values. Replace every `<project>`
placeholder after copying the reference files; do not run the reference files
unchanged.

| Setting | Template value |
| --- | --- |
| Dockerfile | `local/dev/dev.dockerfile` (or the target location) |
| Build context | `<project>` repository root |
| Image | `<project>` |
| Container | `<project>_dev` |
| Host workspace | Parent directory containing the `<project>` repository |
| Container workspace | `/workspace` |
| Working directory | `/workspace/<project>` |
| Persistent command | `sleep infinity` |
| Interactive shell | `bash` |
| History mount | `local/dev/bash_history` to `/root/.bash_history` |
| Networking | Host network |
| GPU | Enabled when the NVIDIA Docker runtime is detected |
| GUI | Local or SSH-forwarded X11 when available |
