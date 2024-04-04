# syntax=docker/dockerfile:1

FROM alpine:latest AS builder

ARG POCKETBASE_VERSION=0.22.7

RUN apk add --no-cache \
    ca-certificates \
    unzip

ADD https://github.com/pocketbase/pocketbase/releases/download/v${POCKETBASE_VERSION}/pocketbase_${POCKETBASE_VERSION}_linux_amd64.zip /tmp/pocketbase.zip

RUN unzip /tmp/pocketbase.zip -d /tmp/pocketbase

RUN chmod +x /tmp/pocketbase/pocketbase

### Final image

FROM alpine:latest
LABEL "maintainer"="Sony AK <sony@sony-ak.com>"

COPY --from=builder /tmp/pocketbase /app/pocketbase

EXPOSE 8090

CMD [ "/app/pocketbase/pocketbase", "serve", "--http=0.0.0.0:8090", "--dir=/app/data/pb_data", "--publicDir=/app/data/pb_public" ]
