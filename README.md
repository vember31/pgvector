# pgvector CNPG

This repository provides a pgvector extension image for [CloudNativePG][cnpg] using the
[ImageVolume extension model][image-volumes] introduced in CNPG 1.27.

Rather than shipping a full PostgreSQL image, we produce a lightweight `FROM scratch` image
containing only the pgvector shared library and extension control files. CloudNativePG
automatically mounts the image volume and configures extension paths without requiring a
custom base image.

## Requirements

- CNPG ≥ 1.27
- Kubernetes ≥ 1.33 (with ImageVolume feature gate) or ≥ 1.35 (GA)

## Image Tags

Three tagging patterns are available:

- **`pg18`** — Updated with every new pgvector release and weekly check; suitable for non-production use
- **`0.8.2-pg18`** — Version-pinned tag created on each build; recommended for production
- **`pg18-sha-abc1234`** — Pinned to specific commits

## Getting Started

### Step 1: Configure Registry Access (optional)

Make the GHCR package public via repository settings, or create a Kubernetes pull secret:

```sh
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=<username> \
  --docker-password=<token> \
  --docker-email=<email>
```

### Step 2: Add the extension to your CNPG Cluster

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: postgres
spec:
  instances: 3
  postgresql:
    extensions:
      - name: pgvector
        image:
          reference: ghcr.io/vember31/pgvector:0.8.2-pg18
```

> **Note:** pgvector does **not** require `shared_preload_libraries`. No postgresql parameter changes are needed.

### Step 3: Create the extension in your database

```sql
CREATE EXTENSION IF NOT EXISTS vector;
```

## Local Building

```sh
docker buildx build \
  --build-arg PG_MAJOR=18 \
  --build-arg DISTRO=trixie \
  -t pgvector:pg18 \
  .
```

## Troubleshooting

If you encounter a `could not open extension control file` error, verify that:

1. The extension image is referenced in your Cluster manifest under `spec.postgresql.extensions`
2. You are running CNPG ≥ 1.27 with the ImageVolume feature available

[cnpg]: https://cloudnative-pg.io
[image-volumes]: https://cloudnative-pg.io/documentation/current/image_volumes/
