#!/bin/sh
set -e

if [ ! -f /etc/sftp/users.conf ]; then
    echo "ERROR: /etc/sftp/users.conf not found" >&2
    exit 1
fi

# Create users from users.conf
# Format: username::uid:gid (password field empty = no password)
while IFS=: read -r user _ uid gid _; do
    [ -z "$user" ] && continue
    case "$user" in \#*) continue ;; esac

    addgroup -g "$gid" "$user" 2>/dev/null || true
    adduser -D -u "$uid" -G "$user" -s /sbin/nologin \
            -h "/home/$user" "$user" 2>/dev/null || true

    # ChrootDirectory requires home owned by root:root, mode 755
    chown root:root "/home/$user"
    chmod 755 "/home/$user"

    if [ ! -f "/etc/sftp/keys/$user" ]; then
        echo "WARNING: No public key for user $user at /etc/sftp/keys/$user" >&2
    fi
done < /etc/sftp/users.conf

# Generate host keys on first boot (persist on PVC)
if [ ! -f /etc/ssh/host_keys/ssh_host_ed25519_key ]; then
    echo "Generating ed25519 host key..."
    ssh-keygen -t ed25519 -f /etc/ssh/host_keys/ssh_host_ed25519_key -N ""
fi
if [ ! -f /etc/ssh/host_keys/ssh_host_rsa_key ]; then
    echo "Generating RSA host key..."
    ssh-keygen -t rsa -b 4096 -f /etc/ssh/host_keys/ssh_host_rsa_key -N ""
fi

echo "Starting sshd..."
exec /usr/sbin/sshd -D -e -o "LogLevel=${SFTP_LOG_LEVEL:-INFO}"
