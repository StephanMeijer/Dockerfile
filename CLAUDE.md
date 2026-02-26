# Claude Code Instructions

## Versioning

Images are versioned via comments at the top of each Dockerfile:

```dockerfile
# image: ghcr.io/stephanmeijer/<name>
# tags: latest, x.y.z
```

**Always follow [Semantic Versioning](https://semver.org/) strictly:**

- `MAJOR` — incompatible change: removed mount path, changed `users.conf` format,
  changed default behaviour, renamed or removed ENV var
- `MINOR` — backwards-compatible new feature: new ENV var, new optional mount,
  new supported format
- `PATCH` — backwards-compatible bug fix or internal change: fixed a bug in the
  entrypoint, updated a log message, security patch with no interface change

Before committing any change to an image, bump the `# tags:` line in its
Dockerfile. Both `latest` and the new semver tag must always be present.

## Pushing

**Always ask the user to confirm before running `git push`**, even if they said
"go ahead" earlier in the conversation. Confirm:

1. The version bump (show old → new)
2. That you are about to push to `origin main`
