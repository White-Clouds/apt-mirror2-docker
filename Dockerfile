# Use Alpine Linux as the base image
FROM alpine:3.19.1

# Set environment variables
ENV TZ=Asia/Shanghai \
    CRON_SCHEDULE="0 2,8,14,20 * * *"

# Expose Nginx port 80
EXPOSE 80

# Update software sources and install necessary packages
RUN apk update \
    && apk upgrade \
    && apk add \
        nginx python3 py3-pip tzdata dpkg \
    && pip3 install --no-cache-dir --break-system-packages \
        apt-mirror==6 uvloop \
    && pip3 cache purge \
    && pip3 uninstall --no-cache-dir --break-system-packages -y \
		pip setuptools wheel \
    && apk del py3-pip \
    && rm -rf /root/.config/pip \
    && rm -rf /var/cache/apk/*

# Copy the nginx configuration file to the corresponding directory
COPY default.conf /etc/nginx/http.d/default.conf

# Copy .sh script to the container
COPY check.sh healthcheck.sh entrypoint.sh /

# Set the execution permissions for script
RUN chmod +x /check.sh /healthcheck.sh /entrypoint.sh

# Add health check
HEALTHCHECK --interval=5m --timeout=10s --start-period=10s --retries=3 CMD /bin/sh /healthcheck.sh

# Set ENTRYPOINT
ENTRYPOINT ["/entrypoint.sh"]
