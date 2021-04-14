ARG BASE
FROM ${BASE}

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    libssl-dev \
    musl-tools

ARG OPENSSL
RUN mkdir -p /usr/local/musl/include \
    && ln -s /usr/include/x86_64-linux-gnu/asm /usr/local/musl/include/asm \
    && ln -s /usr/include/asm-generic /usr/local/musl/include/asm-generic \
    && ln -s /usr/include/linux /usr/local/musl/include/linux \
    && TAG=OpenSSL_$(echo ${OPENSSL} | perl -pe 's/\./_/g') \
    && curl -L https://github.com/openssl/openssl/archive/${TAG}.tar.gz \
    | tar -zxf - \
    && cd openssl-${TAG}/ \
    # https://github.com/openssl/openssl/issues/7207#issuecomment-420814524
    && CC=musl-gcc ./Configure --prefix=/usr/local/musl/ \
    linux-x86_64 no-shared no-zlib -fPIC -DOPENSSL_NO_SECURE_MEMORY \
    && C_INCLUDE_PATH=/usr/local/musl/include/ make -j $(nproc) \
    && make install

ARG BASE
FROM ${BASE}

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    musl-tools \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=0 /usr/local/musl/ /usr/local/musl/

ARG TOOLCHAIN
ENV CARGO_HOME=/usr/local/cargo \
    RUSTUP_HOME=/usr/local/rustup
RUN curl https://sh.rustup.rs \
    | sh -s -- -y \
    --default-toolchain ${TOOLCHAIN} \
    --no-modify-path \
    --target x86_64-unknown-linux-musl

ENV CARGO_BUILD_TARGET=x86_64-unknown-linux-musl \
    PATH=${CARGO_HOME}/bin:${PATH} \
    PKG_CONFIG_ALLOW_CROSS=true \
    PKG_CONFIG_ALL_STATIC=true \
    X86_64_UNKNOWN_LINUX_MUSL_OPENSSL_DIR=/usr/local/musl/ \
    X86_64_UNKNOWN_LINUX_MUSL_OPENSSL_STATIC=1

RUN cargo install --git https://github.com/Hakuyume/sccache.git --branch enhance --all-features \
    && rm -rf ${CARGO_HOME}/git/ ${CARGO_HOME}/registry/cache/ ${CARGO_HOME}/registry/src/

ENV RUSTC_WRAPPER=sccache \
    SCCACHE_DIR=/var/cache/sccache/
ENTRYPOINT ["sh", "-ec", "trap 'sccache --stop-server' EXIT; sccache --start-server; \"$@\"", "--"]
