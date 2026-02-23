#!/usr/bin/env bash
set -euo pipefail

# Default values
BUILD_CONFIG="${BUILD_CONFIG:-docker/build_config.yaml}"
BUILD_TYPE="${BUILD_TYPE:-Release}"
TARGET="${TARGET:-all}"

usage() {
    echo "Usage: bash docker/build.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --config <path>    Build config YAML (default: docker/build_config.yaml)"
    echo "  --build-type <type> CMake build type: Release|Debug|RelWithDebInfo|MinSizeRel (default: Release)"
    echo "  --target <name>    Build specific target (default: all)"
    echo "  --clean            Clean build directories before building"
    echo "  --help             Show this help message"
    exit 0
}

CLEAN_FLAG=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --config)     BUILD_CONFIG="$2"; shift 2 ;;
        --build-type) BUILD_TYPE="$2"; shift 2 ;;
        --target)     TARGET="$2"; shift 2 ;;
        --clean)      CLEAN_FLAG="--CleanAll"; shift ;;
        --help)       usage ;;
        *)            echo "Unknown option: $1"; usage ;;
    esac
done

echo "=== AYON USD Resolver - Linux Docker Build ==="
echo "Config:     ${BUILD_CONFIG}"
echo "Build type: ${BUILD_TYPE}"
echo "Target:     ${TARGET}"
echo "HFS:        ${HFS:-not set}"
echo ""

# Source Houdini environment if available
# Temporarily relax unbound-variable check — houdini_setup_bash references
# variables (JAVA_HOME, etc.) that may not be set in a minimal container.
if [[ -f "${HFS}/houdini_setup_bash" ]]; then
    echo "Sourcing Houdini environment from ${HFS}..."
    set +eu
    pushd "${HFS}" > /dev/null
    source houdini_setup_bash
    popd > /dev/null
    set -eu
fi

# Initialize git submodules
echo "Initializing git submodules..."
git submodule update --init --recursive

# Setup project (creates venv, installs pip packages)
echo "Setting up project..."
python3 Project.py --setup

# Run build
echo "Building..."
python3 Project.py \
    --setVars "{\"BuildConf\": \"${BUILD_CONFIG}\", \"CMakeArgs\": {}}" \
    --BuildType "${BUILD_TYPE}" \
    --Target "${TARGET}" \
    ${CLEAN_FLAG} \
    --runStageGRP "Build and Zip"

echo ""
echo "=== Build complete ==="
echo "Artifacts in: Resolvers/"
ls -la Resolvers/ 2>/dev/null || echo "(no output yet)"
