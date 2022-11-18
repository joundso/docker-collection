FROM rocker/verse:4.2.2

LABEL org.label-schema.schema-version="1.0" \
  org.label-schema.url="https://github.com/joundso/docker-collection"

RUN install2.r --error --deps TRUE --skipinstalled \
  distill

RUN rm -rf /tmp/downloaded_packages & \
  rm -rf /var/lib/apt/lists/*
