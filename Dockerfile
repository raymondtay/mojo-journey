FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG USERNAME=developer

RUN apt-get update && apt-get install -y \
  curl \
  git \
  bash \
  ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# Install Pixi system-wide
RUN curl -fsSL https://pixi.sh/install.sh | bash \
  && mv /root/.pixi/bin/pixi /usr/local/bin/pixi \
  && pixi --version

# When using Docke ron macOS, let Linux allocate IDs for `developer`
# Don't force UID/GID 1000
RUN groupadd developer \
  && useradd \
  --gid developer \
  --create-home \
  --shell /bin/bash \
  developer

WORKDIR /app

COPY pixi.toml pixi.lock* ./

RUN pixi install

COPY . .

RUN chown -R ${USERNAME}:${USERNAME} /app

USER ${USERNAME}

CMD ["/bin/bash"]






