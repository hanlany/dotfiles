#!/usr/bin/env bash

set -euo pipefail

container_name="ogbench_dev"

if ! docker container inspect "${container_name}" >/dev/null 2>&1; then
    echo "Container '${container_name}' does not exist." >&2
    echo "Create it with ./spawn.sh." >&2
    exit 1
fi

if [[ "$(docker inspect --format '{{.State.Running}}' "${container_name}")" == "true" ]]; then
    echo "Container '${container_name}' is already running. Open a shell with ./attach.sh."
    exit 0
fi

current_display="${DISPLAY:-}"
container_display="$(
    docker inspect \
        --format '{{range .Config.Env}}{{println .}}{{end}}' \
        "${container_name}" 2>/dev/null | sed -n 's/^DISPLAY=//p' | head -n 1
)"

if [[ -n "${current_display}" ]]; then
    if [[ "${current_display}" == localhost:* || "${current_display}" == 127.0.0.1:* ]]; then
        echo "SSH-forwarded X11 display detected; skipping xhost."
        if [[ -n "${container_display}" && "${container_display}" != "${current_display}" ]]; then
            echo "Warning: ${container_name} was created with DISPLAY=${container_display}, but this session is using DISPLAY=${current_display}."
            echo "A restarted container may not be able to open GUI apps over this SSH session."
            echo "If that happens, recreate it with ./spawn.sh from this login."
        fi
    elif command -v xhost >/dev/null 2>&1; then
        xhost +local:docker
    else
        echo "xhost not found; continuing without updating local X11 access."
    fi
else
    echo "No X11 display detected; starting container without GUI forwarding."
fi

docker start "${container_name}"
echo "Container '${container_name}' is running. Open a shell with ./attach.sh."
