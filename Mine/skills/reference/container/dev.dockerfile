FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    MUJOCO_GL=egl \
    NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=compute,utility,graphics

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    ffmpeg \
    git \
    libegl1 \
    libgles2 \
    libgl1 \
    libgl1-mesa-dev \
    libglew-dev \
    libglfw3 \
    libglfw3-dev \
    libosmesa6 \
    libosmesa6-dev \
    libx11-6 \
    libxext6 \
    libxrender1 \
    openssh-client \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    tar \
    vim \
    tmux \
    wget \
    curl \
    bubblewrap \
    && rm -rf /var/lib/apt/lists/*
    
RUN curl -fsSL https://chatgpt.com/codex/install.sh | sh

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1 \
    && python -m pip install --upgrade pip setuptools wheel
    
RUN python -m pip install torch pytest

WORKDIR /workspace/ogbench

# Build with the OGBench repository root as the Docker context, e.g.
# `./local/dev/build.sh` or `docker build -t ogbench -f local/dev/Dockerfile .`
COPY . /workspace/ogbench

RUN python -m pip install -e ".[train,dev]"

CMD ["/bin/bash"]
