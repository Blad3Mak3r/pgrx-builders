FROM debian:trixie

ENV DEBIAN_FRONTEND=noninteractive

# ARG para la versión de PostgreSQL
ARG PG_VERSION
RUN test -n "$PG_VERSION" || (echo "PG_VERSION no está definido" && false)

# Instalar dependencias y configurar repositorio de PostgreSQL en una sola capa
RUN apt-get update && apt-get install -y \
    curl \
    libclang-dev \
    build-essential \
    libreadline-dev \
    zlib1g-dev \
    flex \
    bison \
    libxml2-dev \
    libxslt-dev \
    libssl-dev \
    libxml2-utils \
    xsltproc \
    ccache \
    pkg-config \
    gnupg \
    postgresql-common \
    && yes '' | /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh \
    && apt-get update \
    && apt-get install -y \
        postgresql-${PG_VERSION} \
        postgresql-server-dev-${PG_VERSION} \
    && rm -rf /var/lib/apt/lists/*

# Instalar Rust (para CI está bien en root)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
ENV PATH="/root/.cargo/bin:${PATH}"

# Instalar cargo-pgrx
RUN cargo install cargo-pgrx --locked

# Inicializar pgrx con la versión seleccionada
RUN cargo pgrx init --pg${PG_VERSION}=$(which pg_config)

# Configurar ccache para acelerar compilaciones
ENV PATH="/usr/lib/ccache:${PATH}"
ENV CCACHE_DIR="/workspace/.ccache"

WORKDIR /workspace

# Metadata
LABEL org.opencontainers.image.source="https://github.com/blad3mak3r/pgrx-builders"
LABEL org.opencontainers.image.description="PGRX Builder for PostgreSQL ${PG_VERSION}"
LABEL org.opencontainers.image.licenses="MIT"
