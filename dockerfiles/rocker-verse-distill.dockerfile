## BASE_IMAGE_TAG will be overwritten in the build process:
ARG  BASE_IMAGE_TAG

FROM rocker/verse:${BASE_IMAGE_TAG}

LABEL org.label-schema.schema-version="1.0" \
  org.label-schema.url="https://github.com/joundso/docker-collection"

RUN install2.r --error --deps TRUE --skipinstalled \
  distill

RUN rm -rf /tmp/downloaded_packages & \
  rm -rf /var/lib/apt/lists/*
