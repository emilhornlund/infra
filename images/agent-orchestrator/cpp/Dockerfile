ARG BASE_IMAGE=agent-orchestrator-base:local
FROM ${BASE_IMAGE}

ENV SDL_VIDEODRIVER=dummy
ENV SDL_AUDIODRIVER=dummy

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ccache \
        clang-22 \
        clang-format-22 \
        clang-tidy-22 \
        cmake \
        ninja-build \
        pkg-config \
        python3 \
        nasm \
        tar \
        gnome-desktop-testing \
        libasound2-dev \
        libpulse-dev \
        libaudio-dev \
        libfribidi-dev \
        libjack-dev \
        libsndio-dev \
        libx11-dev \
        libxext-dev \
        libxrandr-dev \
        libxcursor-dev \
        libxfixes-dev \
        libxi-dev \
        libxss-dev \
        libxtst-dev \
        libxkbcommon-dev \
        libdrm-dev \
        libgbm-dev \
        libgl1-mesa-dev \
        libgles2-mesa-dev \
        libegl1-mesa-dev \
        libdbus-1-dev \
        libibus-1.0-dev \
        libudev-dev \
        libthai-dev \
        libusb-1.0-0-dev \
        libpipewire-0.3-dev \
        libwayland-dev \
        libdecor-0-dev \
        liburing-dev \
    && rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/clang-22 /usr/local/bin/clang \
    && ln -s /usr/bin/clang++-22 /usr/local/bin/clang++ \
    && ln -s /usr/bin/clang-format-22 /usr/local/bin/clang-format \
    && ln -s /usr/bin/clang-tidy-22 /usr/local/bin/clang-tidy
