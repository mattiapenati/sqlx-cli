build:
    docker buildx build --progress=plain --build-arg SQLX_CLI_VERSION=0.7.1 --tag=sqlx-cli .

run: build
    docker run --rm -it sqlx-cli
