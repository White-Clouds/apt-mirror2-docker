# Similar as the initial build in https://gitlab.com/apt-mirror2/apt-mirror2/-/blob/master/Dockerfile
FROM python:alpine as builder
SHELL ["/bin/sh", "-ex", "-c"]

RUN apk update ;\
    apk upgrade ;\
    apk add --no-cache binutils ;\
    rm -rf /var/cache/apk/* ;\
    apk cache clean ;\
    wget https://gitlab.com/apt-mirror2/apt-mirror2/-/archive/v7/apt-mirror2-v7.tar.gz ;\
    mkdir -p /tmp/apt-mirror2/ ;\
    tar -xzf apt-mirror2-v7.tar.gz --strip-components=1 -C /tmp/apt-mirror2/ ;\
    rm -rf apt-mirror2-v7.tar.gz ;\
    cd /tmp/apt-mirror2 ;\
    pip --disable-pip-version-check --no-cache-dir install \
        -r requirements.txt \
        -r requirements/dev.txt ;\
    pip install . ;\
    cd / ;\
    rm -rf /tmp/apt-mirror2 ;\
    pyinstaller \
        --clean \
        --onefile \
        --noconfirm \
        --name apt-mirror \
        /usr/local/bin/apt-mirror

# Customize, add Nginx
FROM alpine:3
SHELL ["/bin/sh", "-ex", "-c"]

ENV TZ=Asia/Shanghai \
    CRON_SCHEDULE="0 2,8,14,20 * * *"

EXPOSE 80

COPY --from=builder /dist/apt-mirror /usr/local/bin/apt-mirror

RUN apk update &&\
    apk upgrade &&\
    apk add --no-cache tzdata &&\
    rm -rf /var/cache/apk/* &&\
    apk cache clean

COPY check.sh healthcheck.sh entrypoint.sh /

RUN chmod +x /check.sh /healthcheck.sh /entrypoint.sh

HEALTHCHECK --interval=5m --timeout=10s --start-period=10s --retries=3 CMD /bin/sh /healthcheck.sh

ENTRYPOINT ["/entrypoint.sh"]
