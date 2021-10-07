FROM nginxinc/nginx-unprivileged:alpine
COPY ./tmp_build_patient_browser/build /usr/share/nginx/html
CMD ["sh", "-c", "nginx -g 'daemon off;'"]
