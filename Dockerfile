# build envirnment
FROM ubuntu:18.04 AS build

# environment variables
ENV \
    APP_DIR=/opt/app \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8 \
    TZ=UTC \
    DEBIAN_FRONTEND=noninteractive
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# install base build dependencies and useful packages
RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        cargo \
        ca-certificates \
        git \
        && \
    apt-get clean

# build dump_ciede2000
ENV \
    CIEDE_DIR=/opt/dump_ciede2000
RUN \
    mkdir -p $(dirname ${CIEDE_DIR}) && \
    git clone https://github.com/edmond-zhu/dump_ciede2000 ${CIEDE_DIR} && \
    cd ${CIEDE_DIR} && \
    cargo build --release && \
    cargo install --path .

# runtime environment
FROM ubuntu:18.04

ENV \
    TZ=UTC \
    DEBIAN_FRONTEND=noninteractive
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends && \
    apt-get clean

# install dump_ciede2000
ENV CIEDE_BIN=/root/.cargo/bin
COPY --from=build $CIEDE_BIN $CIEDE_BIN
ENV PATH=$PATH:$CIEDE_BIN
