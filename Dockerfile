# Leka - LekaOS
# Copyright 2021 APF France handicap
# SPDX-License-Identifier: Apache-2.0

#
# Mark: - Set global arguments/variables
#

ARG ARM_TOOLCHAIN_FILENAME="gcc-arm-none-eabi-*-x86_64-linux.tar.bz2"
ARG ARM_TOOLCHAIN_EXTRACT_DIRECTORY="gcc-arm-none-eabi-*"
ARG ARM_TOOLCHAIN_URL="https://developer.arm.com/-/media/Files/downloads/gnu-rm/10-2020q4/gcc-arm-none-eabi-10-2020-q4-major-x86_64-linux.tar.bz2"

ARG CLANG_TOOLCHAIN_FILENAME="clang+llvm-*-x86_64-linux-gnu-ubuntu-20.04.tar.xz"
ARG CLANG_TOOLCHAIN_EXTRACT_DIRECTORY="clang+llvm-*-x86_64-linux-gnu-ubuntu-20.04"
ARG CLANG_TOOLCHAIN_URL="https://github.com/llvm/llvm-project/releases/download/llvmorg-12.0.0/clang+llvm-12.0.0-x86_64-linux-gnu-ubuntu-20.04.tar.xz"

ARG SONARCLOUD_CLI_FILENAME="sonar-scanner-cli-*-linux.zip"
ARG SONARCLOUD_CLI_EXTRACT_DIRECTORY="sonar-scanner-*-linux"
ARG SONARCLOUD_CLI_URL="https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.6.2.2472-linux.zip"

ARG SONARCLOUD_BUILD_WRAPPER_FILENAME="build-wrapper-linux-x86.zip"
ARG SONARCLOUD_BUILD_WRAPPER_EXTRACT_DIRECTORY="build-wrapper-linux-x86"
ARG SONARCLOUD_BUILD_WRAPPER_URL="https://sonarcloud.io/static/cpp/build-wrapper-linux-x86.zip"

ARG APT_CLEAN_CACHE="rm -rf /var/lib/apt/lists/*"

#
# Mark: - Download arm-none-eabi toolchain
#

FROM alpine:latest AS download_arm_toolchain

ARG ARM_TOOLCHAIN_URL
ARG ARM_TOOLCHAIN_FILENAME

WORKDIR /

RUN apk --no-cache add wget unzip bzip2

COPY /archives/${ARM_TOOLCHAIN_FILENAME} /
RUN [ -f ${ARM_TOOLCHAIN_FILENAME} ] || wget ${ARM_TOOLCHAIN_URL}
RUN tar -xjf ${ARM_TOOLCHAIN_FILENAME}

#
# Mark: - Download Clang toolchain
#

FROM alpine:latest AS download_clang_toolchain

ARG CLANG_TOOLCHAIN_URL
ARG CLANG_TOOLCHAIN_FILENAME

WORKDIR /

RUN apk --no-cache add wget unzip bzip2

COPY /archives/${CLANG_TOOLCHAIN_FILENAME} /
RUN [ -f ${CLANG_TOOLCHAIN_FILENAME} ] || wget ${CLANG_TOOLCHAIN_URL}
RUN tar -xJf ${CLANG_TOOLCHAIN_FILENAME}

#
# Mark: - Download SonarCloud tools
#

FROM alpine:latest AS download_sonarcloud_tools

ARG SONARCLOUD_CLI_URL
ARG SONARCLOUD_CLI_FILENAME

ARG SONARCLOUD_BUILD_WRAPPER_URL
ARG SONARCLOUD_BUILD_WRAPPER_FILENAME

WORKDIR /

RUN apk --no-cache add wget unzip bzip2

COPY /archives/${SONARCLOUD_CLI_FILENAME} /
RUN [ -f ${SONARCLOUD_CLI_FILENAME} ] || wget ${SONARCLOUD_CLI_URL}
RUN unzip ${SONARCLOUD_CLI_FILENAME}

COPY /archives/${SONARCLOUD_BUILD_WRAPPER_FILENAME} /
RUN [ -f ${SONARCLOUD_BUILD_WRAPPER_FILENAME} ] || wget ${SONARCLOUD_BUILD_WRAPPER_URL}
RUN unzip ${SONARCLOUD_BUILD_WRAPPER_FILENAME}

#
# Mark: - Create clang-format ci image
#

FROM ubuntu:latest AS ci_clang_format

ARG APT_CLEAN_CACHE
ARG DEBIAN_FRONTEND=noninteractive

ARG CLANG_TOOLCHAIN_EXTRACT_DIRECTORY

WORKDIR /workspace/tools/clang

COPY --from=download_clang_toolchain /${CLANG_TOOLCHAIN_EXTRACT_DIRECTORY}/bin/clang-format ./bin/clang-format

ENV PATH="/workspace/tools/clang/bin:${PATH}"

RUN apt update && apt install -y --no-install-recommends python3 \
	&& apt autoremove -y \
	&& ${APT_CLEAN_CACHE}
