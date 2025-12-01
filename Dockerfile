FROM debian:trixie

ENV DEBIAN_FRONTEND=noninteractive

# ARG para la versión de PostgreSQL
ARG PG_VERSION

# Instalar dependencias básicas y agregar repositorio oficial de PostgreSQL
RUN apt-get update && apt-get install -y \
    libclang-dev \
    uild-essential \
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
    && rm -rf /var/lib/apt/lists/*

# Agregar repositorio oficial de PostgreSQL
RUN curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/postgresql-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/postgresql-keyring.gpg] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Instalar postgresql-server-dev según versión
RUN apt-get update && apt-get install -y \
    postgresql-server-dev-${PG_VERSION} \
    && rm -rf /var/lib/apt/lists/*

# Instalar Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
ENV PATH="/root/.cargo/bin:${PATH}"

# Instalar cargo-pgrx
RUN cargo install cargo-pgrx --locked

# Inicializar pgrx con la versión seleccionada
RUN cargo pgrx init --pg${PG_VERSION}=/usr/lib/postgresql/${PG_VERSION}/bin/pg_config

WORKDIR /workspace

# Metadata
LABEL org.opencontainers.image.source="https://github.com/blad3mak3r/pgrx-builders"
LABEL org.opencontainers.image.description="PGRX Builder for PostgreSQL ${PG_VERSION}"
LABEL org.opencontainers.image.licenses="MIT"
