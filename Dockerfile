###############################################################################
# Project Zomboid Server Manager - Docker image
# Game files are downloaded on first start into a volume, not baked in.
###############################################################################
FROM ubuntu:24.04

ARG PZ_UID=1000
ARG PZ_GID=1000
ARG INSTALL_PLAYIT=true

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PZ_DOCKER=1

# lib32gcc-s1/lib32stdc++6: SteamCMD, procps: pgrep/pkill, iproute2: ss,
# nano/less: config editor and log viewer, tini: PID 1 signal forwarding
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates curl gpg sudo tini procps iproute2 hostname \
        nano less lib32gcc-s1 lib32stdc++6 \
    && rm -rf /var/lib/apt/lists/*

# Playit.gg agent as a static binary (the apt package expects systemd)
RUN if [ "$INSTALL_PLAYIT" = "true" ]; then \
        curl -fsSL -o /usr/local/bin/playit \
            https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64 \
        && chmod +x /usr/local/bin/playit; \
    fi

# Ubuntu 24.04 ships a default "ubuntu" user at UID/GID 1000; replace it
RUN userdel -r ubuntu 2>/dev/null || true \
    && groupadd -g "$PZ_GID" pz \
    && useradd -m -u "$PZ_UID" -g "$PZ_GID" -s /bin/bash pz \
    && echo "pz ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/pz \
    && chmod 0440 /etc/sudoers.d/pz

# Scripts are synced from here into ~/manager on every start (see entrypoint)
COPY --chown=pz:pz . /opt/pzserver-manager/
RUN chmod +x /opt/pzserver-manager/*.sh /opt/pzserver-manager/docker/*.sh

USER pz
# Pre-create volume mount points so named volumes inherit pz ownership
RUN mkdir -p /home/pz/manager /home/pz/pzserver /home/pz/Zomboid
WORKDIR /home/pz/manager

# Game (UDP), Steam (UDP), RCON (TCP)
EXPOSE 16261/udp 16262/udp 8766/udp 8767/udp 27015/tcp

ENTRYPOINT ["/usr/bin/tini", "--", "/opt/pzserver-manager/docker/entrypoint.sh"]
