#!/usr/bin/env bash

set -euo pipefail

container_name="ogbench_dev"

if [[ "$(docker inspect --format '{{.State.Running}}' "${container_name}" 2>/dev/null || true)" != "true" ]]; then
    echo "Container '${container_name}' is not running." >&2
    echo "Start it with ./run.sh, or create it with ./spawn.sh." >&2
    exit 1
fi

# docker exec creates a separate shell. Exiting it leaves the container running.
exec docker exec -it "${container_name}" bash
