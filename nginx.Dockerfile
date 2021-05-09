FROM quay.io/centos/centos:stream AS micro-build

RUN \
  mkdir -p /rootfs && \
  dnf install -y \
    --installroot /rootfs --releasever 8 \
    --setopt install_weak_deps=false --nodocs \
    coreutils-single \
    glibc-minimal-langpack \
    setup \
    openssl \
  && \
  cp -v /etc/yum.repos.d/*.repo /rootfs/etc/yum.repos.d/ && \
  dnf -y module enable \
    --installroot /rootfs \
    nginx:1.18 \
  && \
  dnf install -y \
    --installroot /rootfs \
    --setopt install_weak_deps=false --nodocs \
    nginx-mod-stream \
  && \
  dnf clean all && \
  rm -rf /rootfs/var/cache/* && \
  mkdir /rootfs/run/nginx


FROM scratch AS nginx-micro
LABEL maintainer="Alexandre Chanu <alexandre.chanu@gmail.com>"

COPY --from=micro-build /rootfs/ /

RUN \
  chown -c nginx:nginx /run/nginx

USER nginx
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]

#VOLUME /etc/nginx/nginx.conf
VOLUME /etc/nginx/conf.d
VOLUME /usr/share/nginx/html
EXPOSE 80/tcp
EXPOSE 443/tcp
