# Use Alpine Linux as the base image
FROM alpine:3.19.1

# Update software sources and install necessary packages
RUN apk update \
    && apk upgrade \
    && apk add \
        python3 py3-pip dpkg \
    && pip3 install --no-cache-dir --break-system-packages \
        apt-mirror uvloop \
    && pip3 cache purge \
    && pip3 uninstall --no-cache-dir --break-system-packages -y \
		pip setuptools wheel \
    && apk del py3-pip \
    && rm -rf /root/.config/pip \
    && rm -rf /var/cache/apk/*

# Set ENTRYPOINT
ENTRYPOINT ["/entrypoint.sh"]
