#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ws_root="$(cd "${script_dir}/../../.." && pwd)"
container_name="ogbench_dev"

if docker container inspect "${container_name}" >/dev/null 2>&1; then
    echo "Container '${container_name}' already exists." >&2
    echo "Use ./run.sh to start it or ./attach.sh to open a shell." >&2
    exit 1
fi

touch "${script_dir}/bash_history"

# The Codex sandbox profile declares these workspace paths as mount targets.
# Pre-create them so bubblewrap does not need to mkdir them under restricted
# permissions during command startup.
mkdir -p "${ws_root}/.git" "${ws_root}/.agents" "${ws_root}/.codex"

docker_args=(
    --detach
    --name
    "${container_name}"
    --privileged
    --userns=host
    # Bubblewrap needs nested user/mount namespaces for Codex sandbox helpers.
    # Keep privileged mode and make the Docker security policy explicit.
    --security-opt
    seccomp=unconfined
    --security-opt
    apparmor=unconfined
    --cap-add
    SYS_ADMIN
    --cap-add
    SYS_CHROOT
    -v "${script_dir}/bash_history:/root/.bash_history"
    --network=host
    -v "${ws_root}:/workspace"
    -w /workspace/ogbench
)

if [[ -n "${DISPLAY:-}" ]]; then
    if [[ "${DISPLAY}" == localhost:* || "${DISPLAY}" == 127.0.0.1:* ]]; then
        echo "SSH-forwarded X11 display detected; skipping xhost and X11 socket mount."
        docker_args+=(
            -e "DISPLAY=${DISPLAY}"
            -e XAUTHORITY=/tmp/.Xauthority
            -v "${HOME}/.Xauthority:/tmp/.Xauthority:ro"
        )
    elif command -v xhost >/dev/null 2>&1; then
        xhost +local:docker
        docker_args+=(
            -e "DISPLAY=${DISPLAY}"
            -e XAUTHORITY=/tmp/.Xauthority
            -v "${HOME}/.Xauthority:/tmp/.Xauthority:ro"
            -v /tmp/.X11-unix:/tmp/.X11-unix
        )
    else
        echo "xhost not found; starting container without GUI forwarding."
    fi
else
    echo "No X11 display detected; starting container without GUI forwarding."
fi

if docker info --format '{{json .Runtimes}}' 2>/dev/null | grep -q nvidia; then
    docker_args+=(--gpus all)
else
    echo "NVIDIA Docker runtime not detected; starting container without GPU access."
fi

docker run "${docker_args[@]}" ogbench sleep infinity
echo "Container '${container_name}' is running. Open a shell with ./attach.sh."
