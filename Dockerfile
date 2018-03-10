FROM chibidev/emsdk:latest as builder

ARG version=latest
ENV SDK_VERSION=sdk-tag-${version}-64bit
RUN apt update && \
    apt install -y build-essential git-core cmake
RUN ln -sf /bin/bash /bin/sh
RUN source /emscripten/emsdk_env.sh && \
    emsdk install $SDK_VERSION && \
    emsdk activate $SDK_VERSION && \
    rm -rf /emscripten/clang/*/src && \
    find /emscripten/clang/tag*/build_tag* -mindepth 1 -maxdepth 1 ! \( -name 'bin' -o -name 'share' \) -exec rm -rf {} \; && \
    rm -rf node/*/* && \
    rm /emscripten/zips/*


FROM chibidev/emsdk:latest

RUN apt update && \
    apt install -y nodejs npm && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /
COPY --from=builder /emscripten .
RUN ln -s /usr/bin `find /emscripten/node -mindepth 1`/bin