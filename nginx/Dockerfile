FROM docker.io/nginx:alpine as target

COPY vzd-redirect-transformer.js /etc/nginx/njs/vzd-redirect-transformer.js
COPY nginx.conf /etc/nginx/nginx.conf
COPY tests/dummy.js /usr/share/nginx/html
