# Leka - LekaOS
# Copyright 2021 APF France handicap
# SPDX-License-Identifier: Apache-2.0

ARG ARM_TOOLCHAIN_URL="https://developer.arm.com/-/media/Files/downloads/gnu-rm/10-2020q4/gcc-arm-none-eabi-10-2020-q4-major-x86_64-linux.tar.bz2"
ARG ARM_TOOLCHAIN_TAR_EXTRACT_DIRECTORY="gcc-arm-none-eabi-10-2020-q4-major"

ARG SONARCLOUD_CLI_URL="https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.6.2.2472.zip"
ARG SONARCLOUD_CLI_UNZIP_EXTRACT_DIRECTORY="sonar-scanner-4.6.2.2472"

ARG SONARCLOUD_WRAPPER_URL="https://sonarcloud.io/static/cpp/build-wrapper-linux-x86.zip"
ARG SONARCLOUD_WRAPPER_UNZIP_EXTRACT_DIRECTORY="build-wrapper-linux-x86"

#
# Mark: - Download arm-none-eabi toolchain
#

FROM alpine:latest AS download_arm_toolchain

ARG ARM_TOOLCHAIN_URL

WORKDIR /

RUN apk --no-cache add wget unzip bzip2

# RUN wget -O gcc-arm-none-eabi.tar.bz2 ${ARM_TOOLCHAIN_URL}
COPY gcc-arm-none-eabi-10-2020-q4-major-x86_64-linux.tar.bz2 gcc-arm-none-eabi.tar.bz2
RUN tar -xjf gcc-arm-none-eabi.tar.bz2

#
# Mark: - Download SonarCloud toolchain
#

FROM alpine:latest AS download_sonarcloud_tools

ARG SONARCLOUD_CLI_URL
ARG SONARCLOUD_WRAPPER_URL

WORKDIR /

RUN apk --no-cache add wget unzip bzip2

# RUN wget -O sonarcloud-cli.zip ${SONARCLOUD_CLI_URL}
# RUN wget -O sonarcloud-wrapper.zip ${SONARCLOUD_WRAPPER_URL}
COPY sonar-scanner-cli-4.6.2.2472.zip sonarcloud-cli.zip
COPY build-wrapper-linux-x86.zip sonarcloud-wrapper.zip

RUN unzip sonarcloud-cli.zip
RUN unzip sonarcloud-wrapper.zip

#
# Mark: - Install tools
#

FROM frolvlad/alpine-glibc AS install_tools

RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
	apk --no-cache add curl make cmake clang gcovr lcov ccache openjdk11

#
# Mark: - Create final CI image
#

FROM install_tools AS ci

ARG ARM_TOOLCHAIN_TAR_EXTRACT_DIRECTORY
ARG SONARCLOUD_CLI_UNZIP_EXTRACT_DIRECTORY
ARG SONARCLOUD_WRAPPER_UNZIP_EXTRACT_DIRECTORY

WORKDIR /workspace/tools/gcc-arm-none-eabi

COPY --from=download_arm_toolchain /${ARM_TOOLCHAIN_TAR_EXTRACT_DIRECTORY}/arm-none-eabi ./arm-none-eabi
COPY --from=download_arm_toolchain /${ARM_TOOLCHAIN_TAR_EXTRACT_DIRECTORY}/bin ./bin
COPY --from=download_arm_toolchain /${ARM_TOOLCHAIN_TAR_EXTRACT_DIRECTORY}/lib ./lib

ENV PATH="/workspace/tools/gcc-arm-none-eabi/bin:${PATH}"

WORKDIR /workspace/tools/sonarcloud

COPY --from=download_sonarcloud_tools /${SONARCLOUD_CLI_UNZIP_EXTRACT_DIRECTORY} ./${SONARCLOUD_CLI_UNZIP_EXTRACT_DIRECTORY}
COPY --from=download_sonarcloud_tools /${SONARCLOUD_WRAPPER_UNZIP_EXTRACT_DIRECTORY} ./${SONARCLOUD_WRAPPER_UNZIP_EXTRACT_DIRECTORY}

ENV PATH="/workspace/tools/sonarcloud/${SONARCLOUD_CLI_UNZIP_EXTRACT_DIRECTORY}/bin:${PATH}"
ENV PATH="/workspace/tools/sonarcloud/${SONARCLOUD_WRAPPER_UNZIP_EXTRACT_DIRECTORY}:${PATH}"

WORKDIR /workspace
