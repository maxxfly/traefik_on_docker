FROM alpine:latest

ENV PORT=$PORT

RUN apk --no-cache add ca-certificates tzdata
#RUN ls /bin/*
#RUN rm /bin/sh && ln -s /bin/bash /bin/sh
RUN set -ex; \
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		armhf) arch='armv6' ;; \
		aarch64) arch='arm64' ;; \
		x86_64) arch='amd64' ;; \
		s390x) arch='s390x' ;; \
		*) echo >&2 "error: unsupported architecture: $apkArch"; exit 1 ;; \
	esac; \
	wget --quiet -O /tmp/traefik.tar.gz "https://github.com/traefik/traefik/releases/download/v2.7.0-rc1/traefik_v2.7.0-rc1_linux_$arch.tar.gz"; \
	tar xzvf /tmp/traefik.tar.gz -C /usr/local/bin traefik; \
	rm -f /tmp/traefik.tar.gz; \
	chmod +x /usr/local/bin/traefik

COPY traefik.yaml /etc/traefik.yaml

RUN echo "\n" >> /etc/traefik.yaml
RUN echo "entryPoints:" >> /etc/traefik.yaml
RUN echo "  web:" >> /etc/traefik.yaml
RUN echo "    address: \":${PORT}\"" >> /etc/traefik.yaml


RUN echo $PORT

RUN cat /etc/traefik.yaml

#RUN ls /etc
#RUN cat /etc/traefik.yaml

#COPY entrypoint.sh /
#EXPOSE 80
#ENTRYPOINT ["/entrypoint.sh"]
#CMD /usr/local/bin/traefik --configFile=/etc/traefik.yaml
CMD /usr/local/bin/traefik --entryPoints.web.address=:$PORT --api.insecure=true --log.level=DEBUG --api.dashboard=true
#CMD ["traefik"]

# Metadata
LABEL org.opencontainers.image.vendor="Traefik Labs" \
	org.opencontainers.image.url="https://traefik.io" \
	org.opencontainers.image.title="Traefik" \
	org.opencontainers.image.description="A modern reverse-proxy" \
	org.opencontainers.image.version="v2.7.0-rc1" \
	org.opencontainers.image.documentation="https://docs.traefik.io"
