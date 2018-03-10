FROM chibidev/emsdk:latest as builder

ARG version=latest
ENV SDK_VERSION=sdk-tag-${version}-64bit
RUN apt update && \
    apt install -y build-essential cmake
RUN ln -sf /bin/bash /bin/sh
RUN if [ "${version}" = "latest" ]; then export SDK_VERSION=sdk-tag-`wget -qO - https://raw.githubusercontent.com/kripken/emscripten/incoming/emscripten-version.txt | cut -d '"' -f 2`-64bit; fi && \
    . /emscripten/emsdk_env.sh && \
    emsdk update && \
    emsdk install $SDK_VERSION && \
    emsdk activate $SDK_VERSION && \
    rm -rf /emscripten/clang/*/src && \
    find /emscripten/clang/tag*/build_tag* -mindepth 1 -maxdepth 1 ! \( -name 'bin' -o -name 'share' \) -exec rm -rf {} \; && \
    rm -rf /emscripten/node/*/* && \
    rm /emscripten/zips/*


FROM chibidev/emsdk:latest

RUN apt update && \
    apt install -y nodejs npm && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /
COPY --from=builder /emscripten /emscripten
COPY --from=builder /root/.emscripten /root/.emscripten
RUN ln -sf /bin/bash /bin/sh
RUN ln -s /usr/bin `find /emscripten/node -mindepth 1`/bin && \
    ln -s /usr/bin/nodejs /usr/bin/node && \
    . /emscripten/emsdk_env.sh && \
    emcc -v
