FROM alpine:latest AS build

ARG SQLX_CLI_VERSION

# enable link time optimization
ENV CARGO_PROFILE_RELEASE_LTO=true
# optimize for size
ENV CARGO_PROFILE_RELEASE_OPT_LEVEL=z
# reduce parallel code generation units
ENV CARGO_PROFILE_RELEASE_CODEGEN_UNITS=1

RUN --mount=type=cache,target=/root/.cargo \
    --mount=type=cache,target=/root/.rustup \
    --mount=type=cache,target=/var/cache/apk \
    set -eux; \
    apk update; \
    apk add binutils ca-certificates curl gcc musl-dev; \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --profile minimal -y; \
    source ~/.cargo/env; \
    cargo install sqlx-cli --version ${SQLX_CLI_VERSION} --no-default-features --features rustls,postgres,mysql,sqlite; \
    cp ~/.cargo/bin/sqlx /usr/local/bin/; \
    strip /usr/local/bin/sqlx

FROM scratch

COPY --from=build /usr/local/bin/sqlx /sqlx
ENTRYPOINT ["/sqlx"]
