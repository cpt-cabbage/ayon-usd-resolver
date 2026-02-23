#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${SCRIPT_DIR}/docker-compose.yml"

usage() {
    echo "Usage: bash docker/run.sh <command> [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  build-image    Build the Docker image"
    echo "  shell          Open an interactive shell in the container"
    echo "  build          Run the full build (passes extra args to build.sh)"
    echo ""
    echo "Examples:"
    echo "  bash docker/run.sh build-image"
    echo "  bash docker/run.sh shell"
    echo "  bash docker/run.sh build"
    echo "  bash docker/run.sh build --clean"
    echo "  bash docker/run.sh build --build-type Debug --target Houdini205_Py311_Linux"
    exit 0
}

if [[ $# -lt 1 ]]; then
    usage
fi

COMMAND="$1"
shift

case "${COMMAND}" in
    build-image)
        echo "=== Building Docker image ==="
        docker compose -f "${COMPOSE_FILE}" build "$@"
        ;;
    shell)
        echo "=== Opening interactive shell ==="
        docker compose -f "${COMPOSE_FILE}" run --rm builder bash "$@"
        ;;
    build)
        echo "=== Running build ==="
        docker compose -f "${COMPOSE_FILE}" run --rm builder bash docker/build.sh "$@"
        ;;
    *)
        echo "Unknown command: ${COMMAND}"
        usage
        ;;
esac
