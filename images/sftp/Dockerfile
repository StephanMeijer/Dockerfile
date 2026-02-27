# image: ghcr.io/stephanmeijer/sftp
# tags: latest, 0.3.0
FROM alpine:3.21

RUN apk add --no-cache \
        openssh-server \
        openssh-sftp-server \
    && rm -f /etc/ssh/ssh_host_* \
    && mkdir -p /etc/ssh/host_keys /etc/sftp/keys

COPY sshd_config /etc/ssh/sshd_config
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
