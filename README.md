# Docker Embedded Development Toolchains

## About

Docker images & containers used for LekaOS CI setup using Github Actions and for embedded development.

The Dockerfile is based on [multi-stage builds](https://docs.docker.com/develop/develop-images/multistage-build/).

The following images are available:

## CI - Clang-format

Super lean image to run clang-format on our code base.

### Info

- target: `ci_clang_format`
- name: `weareleka/docker-clang-format:latest`
- base: `ubuntu:latest`
- link: [docker://weareleka/docker-clang-format](https://hub.docker.com/repository/docker/weareleka/docker-clang-format)
- size (compressed): ~40MB
- version: `clang-format version 12.0.0 (https://github.com/llvm/llvm-project/ b978a93635b584db380274d7c8963c73989944a1)`

```bash
# build
docker build --force-rm --rm --target ci_clang_format -t weareleka/docker-clang-format:latest .

# push
docker push weareleka/docker-clang-format:latest

# pull
docker pull weareleka/docker-clang-format:latest

# run interactive
docker run --privileged -it --rm weareleka/docker-clang-format:latest /bin/bash

# run commands
docker run --rm weareleka/docker-clang-format:latest clang-format --version
```

## CI - ARM Toolchain

Ubuntu based image for the [GNU Arm Embedded Toolchain](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm), aka arm-none-eabi-gcc. It also includes the following tools:

- python3 && pip
- curl make ninja-build ccache zstd
- cmake 3.20.4 (latest version)
- [ARMmbed/mbed-cli](https://github.com/ARMmbed/mbed-cli) && [ARMmbed/mbed-os](https://github.com/ARMmbed/mbed-os/) [`requirements.txt`](https://raw.githubusercontent.com/ARMmbed/mbed-os/master/requirements.txt)

### Info

- target: `ci_arm_toolchain`
- name: `weareleka/docker-arm-toolchain:latest`
- base: `ubuntu:latest`
- link: [docker://weareleka/docker-arm-toolchain](https://hub.docker.com/repository/docker/weareleka/docker-arm-toolchain)
- size (compressed): ~260MB
- version: `arm-none-eabi-gcc (GNU Arm Embedded Toolchain 10-2020-q4-major) 10.2.1 20201103 (release)`

```bash
# build
docker build --force-rm --rm --target ci_clang_format -t weareleka/docker-arm-toolchain:latest .

# push
docker push weareleka/docker-arm-toolchain:latest

# pull
docker pull weareleka/docker-arm-toolchain:latest

# run interactive
docker run --privileged -it --rm weareleka/docker-arm-toolchain:latest /bin/bash

# run commands
docker run --rm weareleka/docker-arm-toolchain:latest arm-none-eabi-gcc -v
```
