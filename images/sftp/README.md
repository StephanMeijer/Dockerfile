# sftp

SFTP-only container based on Alpine + OpenSSH. All shell access is disabled
(`ForceCommand internal-sftp`). Each user is chrooted to `/home/<username>`.
Authentication is public key only — password authentication is disabled in the
baked-in `sshd_config`.

## Mounts

| Path | Type | Required | Description |
|---|---|---|---|
| `/etc/sftp/users.conf` | file | yes | User definitions (see format below) |
| `/etc/sftp/keys/` | directory | yes | One file per user containing their authorized public key(s) |
| `/etc/ssh/host_keys/` | directory | yes | Persistent host key storage — mount a PVC here |

### `users.conf` format

One user per line:

```
username::uid:gid
```

- `username` — Linux username and chroot directory name (`/home/<username>`)
- `uid` / `gid` — numeric user and group ID
- Empty lines and lines starting with `#` are ignored

Example:

```
# SFTP users
steve::2000:2000
mikrotik::3000:3000
```

### Keys directory

Each file in `/etc/sftp/keys/` must be named exactly after the username it
belongs to. The file contains one or more SSH public keys, one per line
(standard `authorized_keys` format).

```
/etc/sftp/keys/
    steve        ← authorized_keys for user steve
    mikrotik     ← authorized_keys for user mikrotik
```

### Host keys

The entrypoint generates ed25519 and RSA host keys on first boot if they are
not already present. Mount a persistent volume at `/etc/ssh/host_keys/` to
retain keys across pod restarts (avoids SSH fingerprint warnings for clients).

## Environment variables

| Variable | Default | Description |
|---|---|---|
| `SFTP_LOG_LEVEL` | `INFO` | sshd log level. Valid values: `QUIET`, `FATAL`, `ERROR`, `INFO`, `VERBOSE`, `DEBUG`, `DEBUG1`, `DEBUG2`, `DEBUG3` |

## Docker example

```sh
docker run -d \
  -p 2222:22 \
  -v /path/to/users.conf:/etc/sftp/users.conf:ro \
  -v /path/to/keys:/etc/sftp/keys:ro \
  -v sftp-host-keys:/etc/ssh/host_keys \
  -v /data:/home/steve/data \
  ghcr.io/stephanmeijer/sftp:0.1.0
```

## Kubernetes usage

Mount `users.conf` and the keys directory from ConfigMaps, and host keys from
a PVC:

```yaml
persistence:
  users-conf:
    type: configMap
    name: sftp-users
    globalMounts:
      - path: /etc/sftp/users.conf
        subPath: users.conf
        readOnly: true

  ssh-keys:
    type: configMap
    name: sftp-ssh-keys
    defaultMode: 0444
    globalMounts:
      - path: /etc/sftp/keys
        readOnly: true

  host-keys:
    type: persistentVolumeClaim
    accessMode: ReadWriteOnce
    size: 1Gi
    globalMounts:
      - path: /etc/ssh/host_keys
```

Public keys are not sensitive — a ConfigMap is appropriate. Do not store
private keys in the image or in ConfigMaps.

## Chroot layout

Each user is chrooted to `/home/<username>`. The chroot directory itself must
be owned `root:root` with mode `755` (OpenSSH requirement) — the entrypoint
handles this automatically.

Data volumes should be mounted as subdirectories inside the chroot, e.g.
`/home/steve/data`. From the client's perspective this appears as `data/`.
