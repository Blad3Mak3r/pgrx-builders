FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# ARG para la versión de PostgreSQL
ARG PG_VERSION

# Instalar dependencias + postgresql-server-dev según versión
RUN apt-get update && apt-get install -y \
    build-essential curl ca-certificates git pkg-config libssl-dev \
    postgresql-server-dev-${PG_VERSION}

# Instalar Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Instalar cargo-pgrx
RUN cargo install cargo-pgrx --locked

# Inicializar pgrx con la versión seleccionada
RUN cargo pgrx init --pg${PG_VERSION}=/usr/lib/postgresql/${PG_VERSION}/bin/pg_config

WORKDIR /workspace
