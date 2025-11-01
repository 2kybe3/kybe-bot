FROM rust:latest AS builder

WORKDIR /usr/src/app

COPY Cargo.toml Cargo.lock ./

# Cache layer
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release || true
RUN rm -rf src

# Build layer
COPY src ./src

RUN cargo build --release -j $(nproc) --locked

RUN cargo test

FROM debian:trixie-slim

WORKDIR /opt/kybe-bot

COPY --from=builder /usr/src/app/target/release/kybe-bot /usr/local/bin/

CMD ["kybe-bot"]