# syntax=docker/dockerfile:1

FROM alpine:latest AS builder

ARG POCKETBASE_VERSION=0.22.11

RUN apk add --no-cache \
    ca-certificates \
    unzip

ADD https://github.com/pocketbase/pocketbase/releases/download/v${POCKETBASE_VERSION}/pocketbase_${POCKETBASE_VERSION}_linux_amd64.zip /tmp/pocketbase.zip

RUN unzip /tmp/pocketbase.zip -d /tmp/pocketbase

RUN chmod +x /tmp/pocketbase/pocketbase

#############################################
# Final image
#############################################

FROM alpine:latest
LABEL maintainer="Sony AK <sony@sony-ak.com>"

WORKDIR /app/pocketbase

COPY --from=builder /tmp/pocketbase .

ENV DATA_DIR=/app/data/pb_data
ENV PUBLIC_DIR=/app/data/pb_public
ENV PORT=8090

EXPOSE ${PORT}

CMD [ "sh", "-c", "./pocketbase serve --http=0.0.0.0:${PORT} --dir=${DATA_DIR} --publicDir=${PUBLIC_DIR}" ]
