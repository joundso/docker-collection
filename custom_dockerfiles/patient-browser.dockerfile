FROM alpine/git:1.0.33 as pboriginal
RUN git clone --depth=1 https://github.com/smart-on-fhir/patient-browser.git /tmp

FROM alpine/git:1.0.33 as pbalvearie
RUN git clone --depth=1 https://github.com/Alvearie/patient-browser.git /tmp

FROM nginxinc/nginx-unprivileged:1.21-alpine
LABEL org.label-schema.schema-version="1.0" \
    org.label-schema.url="https://github.com/joundso/docker-collection"

## Add the build folder from alvearie:
COPY --from=pbalvearie /tmp/build /usr/share/nginx/html

## Add the `js` subfolder from the original patient browser:
COPY --from=pboriginal /tmp/build/js /usr/share/nginx/html/js

# COPY ./tmp_build_patient_browser/build /usr/share/nginx/html

CMD ["sh", "-c", "nginx -g 'daemon off;'"]
