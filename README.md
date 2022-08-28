# pocketbase-docker

## What is this?

Dockerized Pocketbase, based on https://github.com/krushiraj/pocketbase-docker/blob/main/Dockerfile and https://github.com/bscott/pocketbase-docker/blob/main/Dockerfile. Just for my use case scenario.

## Notes

- Read the `Dockerfile`.
- Pocketbase expose port 8090 on container.
- Please update `POCKETBASE_VERSION` on `Dockerfile` to the latest version.
- This example is just for own personal use case that using Pocketbase as container, on a sub domain, I am using Nginx container to do reverse proxy and I am using Cloudflare DNS.

## Sample of Docker Compose

```
services:
  be-pocketbase:
    container_name: be-pocketbase
    build: .
    image: be-pocketbase:latest
    volumes:
      - be-pocketbase-volume:/app/pocketbase/pb_data
    networks:
      - infra-net

networks:
  infra-net:
    name: infra-net
    external: true

volumes:
  be-pocketbase-volume:
    name: be-pocketbase-volume
    external: true
```

Run it with `docker compose up -d`

### Sample of Nginx

Nginx also a container and traffic comes from Cloudflare DNS.

```
server {
  listen 443 ssl http2;
  listen [::]:443 ssl http2;

  listen 80;
  listen [::]:80;

  server_name pocketbase.xxx.xxx; # a subdomain

  location / {
    proxy_set_header Connection '';
    proxy_http_version 1.1;
    proxy_read_timeout 180s;

    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;

    proxy_pass http://be-pocketbase:8090;
  }

  ssl_certificate /just_example_of_selfsigned.crt;
  ssl_certificate_key /just_example_of_selfsigned.key;
}
```

