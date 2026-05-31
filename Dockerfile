# syntax=docker/dockerfile:1

# PG_MAJOR: PostgreSQL major version (used for package names, e.g. 18)
ARG PG_MAJOR=18
# PG_IMAGE_TAG: CNPG base image tag — pin to a specific minor version (e.g. 18.4)
# Defaults to PG_MAJOR so it tracks the latest minor release of that major.
ARG PG_IMAGE_TAG=${PG_MAJOR}
# DISTRO: Debian codename used in the CNPG base image tag and the PGDG apt repo (e.g. trixie)
ARG DISTRO=trixie

FROM ghcr.io/cloudnative-pg/postgresql:${PG_IMAGE_TAG}-minimal-${DISTRO} AS builder

# Re-declare after FROM so the values are available in this build stage
ARG PG_MAJOR=18

USER 0

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        "postgresql-${PG_MAJOR}-pgvector" \
    ; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# Extension image: contains only the pgvector extension files.
# CNPG mounts this as an OCI image volume alongside other extension images.
#
# Note: pgvector does NOT require shared_preload_libraries. After mounting,
# simply run in psql:
#   CREATE EXTENSION IF NOT EXISTS vector;
FROM scratch
ARG PG_MAJOR=18

COPY --from=builder /usr/lib/postgresql/${PG_MAJOR}/lib/vector.so /lib/
COPY --from=builder /usr/share/postgresql/${PG_MAJOR}/extension/vector* /share/extension/

USER 65532:65532
