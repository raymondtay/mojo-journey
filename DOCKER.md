# Running Mojo Exercises with Docker

This project provides a Dockerized environment to ensure that the Mojo exercises run consistently across different operating systems (macOS and Linux).

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed and running.
- [Docker Compose](https://docs.docker.com/compose/) (included with Docker Desktop).

## Getting Started

### 1. Build the Environment

Build the Docker image based on the provided `Dockerfile`:

```bash
docker compose build
```

### 2. Run the Environment

Start the container in interactive mode:

```bash
docker compose run --rm mojo-journey bash
```

This will drop you into a bash shell inside the container with all dependencies installed and your local source code mounted to `/app`.

### 3. Executing Exercises

Once inside the container, you can run any Mojo file using `pixi run mojo`:

```bash
# Example: Run the hello world exercise
pixi run mojo 01_basics/01_helloworld.mojo

# Example: Run a test
pixi run mojo tests/test_basics.mojo
```

## Development Workflow

Because the current directory is mounted as a volume, any changes you make to the `.mojo` files on your host machine (macOS/Linux) will be immediately reflected inside the Docker container. You do not need to rebuild the image unless you change the `pixi.toml` dependencies.

### Troubleshooting Permissions

If you encounter permission issues with the volume mount, ensure you are passing your current user ID to the container. `docker-compose.yml` is configured to use `${UID}` and `${GID}`. You can export these in your shell before running:

```bash
export UID=$(id -u)
export GID=$(id -g)
docker compose run --rm mojo-journey bash
```
