# Similar as the initial build in https://gitlab.com/apt-mirror2/apt-mirror2/-/blob/master/Dockerfile
FROM python:alpine as aptMirrorBuilder
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

# Nginx build
FROM alpine:3 as nginxBuilder
SHELL ["/bin/sh", "-ex", "-c"]

RUN apk update && \
    apk upgrade &&\
    apk add --no-cache build-base pcre-dev zlib-dev openssl-dev wget && \
    wget https://nginx.org/download/nginx-1.26.1.tar.gz && \
    tar -xzf nginx-1.26.1.tar.gz && \
    cd nginx-1.26.1 && \
    ./configure \
    --without-http_charset_module \
    --without-http_gzip_module \
    --without-http_ssi_module \
    --without-http_userid_module \
    --without-http_access_module \
    --without-http_auth_basic_module \
    --without-http_mirror_module \
    --without-http_geo_module \
    --without-http_map_module \
    --without-http_split_clients_module \
    --without-http_referer_module \
    --without-http_rewrite_module \
    --without-http_proxy_module \
    --without-http_fastcgi_module \
    --without-http_uwsgi_module \
    --without-http_scgi_module \
    --without-http_grpc_module \
    --without-http_memcached_module \
    --without-http_limit_conn_module \
    --without-http_limit_req_module \
    --without-http_empty_gif_module \
    --without-http_browser_module \
    --without-http_upstream_hash_module \
    --without-http_upstream_ip_hash_module \
    --without-http_upstream_least_conn_module \
    --without-http_upstream_random_module \
    --without-http_upstream_keepalive_module \
    --without-http_upstream_zone_module \
    --without-mail_*_module \
    --without-stream_*_module && \
    make && \
    make install

# Final image
FROM alpine:3
SHELL ["/bin/sh", "-ex", "-c"]

ENV TZ=Asia/Shanghai \
    CRON_SCHEDULE="0 2,8,14,20 * * *"

EXPOSE 80

COPY --from=aptMirrorBuilder /dist/apt-mirror /usr/local/bin/apt-mirror
COPY --from=nginxBuilder /usr/local/nginx/sbin/nginx /usr/local/sbin/nginx
COPY --from=nginxBuilder /usr/local/nginx/conf /etc/nginx

RUN apk update &&\
    apk upgrade &&\
    apk add --no-cache tzdata &&\
    rm -rf /var/cache/apk/* &&\
    apk cache clean

COPY default.conf /etc/nginx/http.d/default.conf

COPY check.sh healthcheck.sh entrypoint.sh /

RUN chmod +x /check.sh /healthcheck.sh /entrypoint.sh

HEALTHCHECK --interval=5m --timeout=10s --start-period=10s --retries=3 CMD /bin/sh /healthcheck.sh

ENTRYPOINT ["/entrypoint.sh"]
