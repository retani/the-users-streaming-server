FROM codeworksio/ubuntu:16.04-20170605

ARG APT_PROXY
ARG APT_PROXY_SSL
ENV NGINX_VERSION="1.11.3" \
    NGINX_RTMP_MODULE_VERSION="1.1.9"

RUN set -ex \
    \
    && buildDeps=' \
        build-essential \
        libpcre3-dev \
        libssl-dev \
    ' \
    && if [ -n "$APT_PROXY" ]; then echo "Acquire::http { Proxy \"http://${APT_PROXY}\"; };" > /etc/apt/apt.conf.d/00proxy; fi \
    && if [ -n "$APT_PROXY_SSL" ]; then echo "Acquire::https { Proxy \"https://${APT_PROXY_SSL}\"; };" > /etc/apt/apt.conf.d/00proxy; fi \
    && apt-get --yes update \
    && apt-get --yes install \
        $buildDeps \
        openssl \
    \
    && cd /tmp \
    && curl -L "https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz" -o nginx-$NGINX_VERSION.tar.gz \
    && tar -xf nginx-$NGINX_VERSION.tar.gz \
    && curl -L "https://github.com/arut/nginx-rtmp-module/archive/v${NGINX_RTMP_MODULE_VERSION}.tar.gz" -o nginx-rtmp-module-$NGINX_RTMP_MODULE_VERSION.tar.gz \
    && tar -xf nginx-rtmp-module-$NGINX_RTMP_MODULE_VERSION.tar.gz \
    && cd /tmp/nginx-$NGINX_VERSION \
    && ./configure \
        --sbin-path=/usr/local/sbin/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --pid-path=/var/run/nginx/nginx.pid \
        --lock-path=/var/lock/nginx/nginx.lock \
        --http-log-path=/var/log/nginx/access.log \
        --http-client-body-temp-path=/tmp/nginx-client-body \
        --with-http_ssl_module \
        --with-threads \
        --with-ipv6 \
        --add-module=/tmp/nginx-rtmp-module-$NGINX_RTMP_MODULE_VERSION \
    && make \
    && make install \
    && mkdir /var/lock/nginx \
    \
    && apt-get purge --yes --auto-remove $buildDeps \
    && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/* /var/cache/apt/* \
    && rm -f /etc/apt/apt.conf.d/00proxy

COPY assets/etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY assets/sbin/bootstrap.sh /sbin/bootstrap.sh

EXPOSE 1935
CMD [ "nginx", "-g", "daemon off;" ]

### METADATA ###################################################################

ARG VERSION
ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL
LABEL \
    version=$VERSION \
    build-date=$BUILD_DATE \
    vcs-ref=$VCS_REF \
    vcs-url=$VCS_URL \
    license="MIT"