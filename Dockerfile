# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install basic dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install pixi
RUN curl -fsSL https://pixi.sh/install.sh | bash
ENV PATH="/root/.pixi/bin:$PATH"

# Set working directory
WORKDIR /app

# Copy pixi configuration files
COPY pixi.toml .
COPY pixi.lock .

# Install dependencies
# We use 'pixi install' to set up the environment inside the image
RUN pixi install

# Default command: start a shell in the pixi environment
# This allows users to run 'docker run -it mojo-journey' and then use 'pixi run mojo ...'
CMD ["bash"]
