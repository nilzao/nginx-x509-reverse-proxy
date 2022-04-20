FROM nginx:1.21-alpine

RUN apk add openssl

COPY docker-entrypoint.d /docker-entrypoint.d
RUN chmod +x /docker-entrypoint.d/*.sh

COPY ca-gen /ca-gen

COPY templates/ /etc/nginx/templates

WORKDIR /ca-gen
