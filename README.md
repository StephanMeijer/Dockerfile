# Dockerfile

Multi-image Docker monorepo. Each image lives in `images/<name>/`, built and pushed to GHCR via GitHub Actions.

## Images

| Image | GHCR | Description |
|---|---|---|
| [sftp](images/sftp/) | `ghcr.io/stephanmeijer/sftp` | SFTP-only container (Alpine + OpenSSH, pubkey auth, per-user chroot) |

## Versioning

Each Dockerfile declares its own image name and tags via comments at the top:

```dockerfile
# image: ghcr.io/stephanmeijer/sftp
# tags: latest, 1.0.0
FROM alpine:3.21
```

- `# image:` (required) — full GHCR image path
- `# tags:` (optional) — comma-separated Docker tags to apply; defaults to `latest` if omitted

CI reads these comments and tags the built image accordingly.

## Workflows

| Workflow | Trigger | Purpose |
|---|---|---|
| CI | PR to `main` | Build test (no push) |
| Release | Push to `main` | Build + push to GHCR |
| Rebuild | Weekly (Mon 06:00 UTC) / manual | Rebuild with `--no-cache` for security patches |

## Adding a new image

1. Create `images/<name>/Dockerfile` with `# image:` and `# tags:` comments
2. Add supporting files (entrypoint scripts, configs, etc.)
3. Add `<name>` to the `matrix.image` array in all three workflow files
4. Push to `main`
