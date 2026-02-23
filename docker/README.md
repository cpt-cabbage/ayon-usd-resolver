# Docker Build Environment for AYON USD Resolver

Build the AYON USD resolver for Linux from macOS (or any Docker-capable host) using a Rocky Linux 9 container.

## Prerequisites

- Docker and Docker Compose
- The Houdini SDK folder (`hfs20.5.584/`) in the repo root

## Quick Start

```bash
# 1. Build the Docker image
bash docker/run.sh build-image

# 2. Run the full build
bash docker/run.sh build
```

Build artifacts appear in `Resolvers/` on your host filesystem.

## Commands

### `run.sh`

A convenience wrapper around all Docker operations:

| Command | Description |
|---------|-------------|
| `bash docker/run.sh build-image` | Build the Docker image |
| `bash docker/run.sh shell` | Open an interactive shell in the container |
| `bash docker/run.sh build` | Run the full automated build |

### Build Options

Extra arguments after `build` are forwarded to `build.sh`:

```bash
bash docker/run.sh build --clean                    # Clean build directories first
bash docker/run.sh build --build-type Debug          # Debug build
bash docker/run.sh build --target Houdini205_Py311_Linux  # Specific target
bash docker/run.sh build --config path/to/config.yaml     # Custom build config
```

| Option | Default | Description |
|--------|---------|-------------|
| `--config <path>` | `docker/build_config.yaml` | Build config YAML file |
| `--build-type <type>` | `Release` | `Release`, `Debug`, `RelWithDebInfo`, or `MinSizeRel` |
| `--target <name>` | `all` | Build a specific target by name |
| `--clean` | off | Clean all build/install dirs before building |

### Direct Docker Compose Usage

If you prefer not to use `run.sh`:

```bash
# Build image
docker compose -f docker/docker-compose.yml build

# Interactive shell
docker compose -f docker/docker-compose.yml run --rm builder bash

# Full build
docker compose -f docker/docker-compose.yml run --rm builder bash docker/build.sh
```

## How It Works

1. The Rocky Linux 9 container provides a Linux build environment with GCC, CMake, and Python 3
2. The repo root is bind-mounted at `/workspace`, so source and build artifacts are shared with the host
3. The Houdini SDK (`hfs20.5.584/`) is mounted read-only at `/opt/hfs20.5.584`
4. `Project.py` sees `platform.system() == "Linux"` and builds only Linux targets
5. `build.sh` handles the full sequence: source Houdini env, init submodules, setup project venv, run the build

## Build Config

The default config (`docker/build_config.yaml`) targets Houdini 20.5 with Python 3.11:

```yaml
Houdini205_Py311_Linux:
  COMPILEPLUGIN: "HouLinux/Houdini205_Py311_Linux"
  HFS: "/opt/hfs20.5.584"
```

Add more targets by appending entries. Available build plugins are in `BuildPlugins/`:

- `HouLinux/` — Houdini on Linux
- `MayaLinux/` — Maya on Linux
- `AyonUsdLinux/` — AYON USD on Linux
- `UnrealLinux/` — Unreal on Linux

## Output

After a successful build, check:

```
Resolvers/Houdini205_Py311_Linux/
├── ayonUsdResolver.so
├── Python/
└── plugInfo.json
```
