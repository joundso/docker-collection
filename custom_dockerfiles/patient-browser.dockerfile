FROM nginxinc/nginx-unprivileged:1.20-alpine

LABEL org.label-schema.schema-version="1.0" \
    org.label-schema.url="https://github.com/joundso/docker-collection"

COPY ./tmp_build_patient_browser/build /usr/share/nginx/html
CMD ["sh", "-c", "nginx -g 'daemon off;'"]
