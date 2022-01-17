## BASE_IMAGE_TAG will be overwritten in the build process:
ARG  BASE_IMAGE_TAG

FROM alpine:${BASE_IMAGE_TAG}

LABEL org.label-schema.schema-version="1.0" \
  org.label-schema.url="https://github.com/joundso/docker-collection"

# Optional Configuration Parameter
ARG SERVICE_USER
ARG SERVICE_HOME

# Default Settings
ENV SERVICE_USER ${SERVICE_USER:-download}
ENV SERVICE_HOME ${SERVICE_HOME:-/home/${SERVICE_USER}}

RUN \
  adduser -h ${SERVICE_HOME} -s /sbin/nologin -u 1000 -D ${SERVICE_USER} && \
  apk add --no-cache \
    bash \
    git \
    dumb-init \
    openssl && \
  sed -i -e "s/bin\/ash/bin\/bash/" /etc/passwd

USER    ${SERVICE_USER}
WORKDIR ${SERVICE_HOME}
VOLUME  ${SERVICE_HOME}

ENTRYPOINT [ "/usr/bin/dumb-init", "git" ]
CMD [ "--help" ]
