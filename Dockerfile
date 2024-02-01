FROM ghcr.io/cirruslabs/flutter:3.10.4 as builder
RUN sudo apt update && sudo apt install curl -y
COPY . /app
WORKDIR /app
RUN ./scripts/build-web.sh

FROM docker.io/nginx:alpine as target
LABEL maintainer="TIMREF Maintainers"
ARG TIM_REF_VERSION="LOCAL_BUILD"
RUN rm -rf /usr/share/nginx/html
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/vzd-redirect-transformer.js /etc/nginx/njs/vzd-redirect-transformer.js
COPY --from=builder /app/build/web /usr/share/nginx/html
RUN sed -i "s/TIM_REF_VERSION/$TIM_REF_VERSION/g" /usr/share/nginx/html/index.html
