# syntax=docker/dockerfile:1

FROM alpine:latest
LABEL "maintainer"="Sony AK <sony@sony-ak.com>"

ARG POCKETBASE_VERSION=0.22.7

RUN apk add --no-cache \
    ca-certificates \
    unzip \
    wget \
    zip \
    zlib-dev

ADD https://github.com/pocketbase/pocketbase/releases/download/v${POCKETBASE_VERSION}/pocketbase_${POCKETBASE_VERSION}_linux_amd64.zip /app/pocketbase/pocketbase.zip

RUN unzip /app/pocketbase/pocketbase.zip -d /app/pocketbase && \
    chmod +x /app/pocketbase/pocketbase && \
    rm /app/pocketbase/pocketbase.zip

EXPOSE 8090

CMD [ "/app/pocketbase/pocketbase", "serve", "--http=0.0.0.0:8090", "--dir=/app/data/pb_data", "--publicDir=/app/data/pb_public" ]
