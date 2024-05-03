# Use Alpine Linux as the base image
FROM alpine:3.19.1

# Set environment variables
ENV TZ=Asia/Shanghai \
    CRON_SCHEDULE="0 2,8,14,20 * * *"

# Expose Nginx port 80
EXPOSE 80

# Update software sources and install necessary packages
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update \
    && apk upgrade \
    && apk add \
        nginx python3 py3-pip tzdata dpkg \
    && pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple \
    && echo "trusted-host = mirrors.aliyun.com" >> /root/.config/pip/pip.conf \
    && pip3 install --no-cache-dir --break-system-packages \
        apt-mirror uvloop \
    && pip3 cache purge \
    && pip3 uninstall --no-cache-dir --break-system-packages -y \
		pip setuptools wheel \
    && apk del py3-pip \
    && rm -rf /root/.config/pip \
    && rm -rf /var/cache/apk/*

# Copy the nginx configuration file to the corresponding directory
COPY default.conf /etc/nginx/http.d/default.conf

# Copy the check.sh script to the container
COPY check.sh /check.sh

# Add health check
COPY healthcheck.sh /healthcheck.sh
RUN chmod +x /healthcheck.sh
HEALTHCHECK --interval=5m --timeout=10s --start-period=10s --retries=3 CMD /bin/sh /healthcheck.sh

# Set LABEL
ARG BUILD_DATE
LABEL org.opencontainers.image.created=$BUILD_DATE
LABEL org.opencontainers.image.licenses="GPL-3.0-or-later"
LABEL org.opencontainers.image.title="apt-mirror2"
LABEL org.opencontainers.image.source="https://gitlab.com/apt-mirror2/apt-mirror2"
LABEL org.opencontainers.image.version="4"

# Copy entrypoint.sh to the container
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set ENTRYPOINT
ENTRYPOINT ["/entrypoint.sh"]
