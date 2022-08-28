# pocketbase-docker

## What is this?

Dockerized Pocketbase (https://github.com/pocketbase/pocketbase), based on https://github.com/krushiraj/pocketbase-docker/blob/main/Dockerfile and https://github.com/bscott/pocketbase-docker/blob/main/Dockerfile. Just for my personal use case scenario.

## Notes

- Read the `Dockerfile`.
- Pocketbase expose port 8090 on container.
- Please update `POCKETBASE_VERSION` on `Dockerfile` to the latest version. See at https://github.com/pocketbase/pocketbase/releases.

## My scenario

- I am using Nginx as a container.
- I am using Pocketbase as a container.
- I am using Cloudflare DNS.
- My Pocketbase is run on a subdomain (pocketbase.xxx.xxx).
- I setup Nginx as reverse proxy to Pocketbase container.
- My Pocketbase container just exposed the port internally, not to host.
- Nginx setup is connect to Pocketbase container.
- My Pocketbase data saved on Docker volume so it will not gone when container removed. Just `docker inspect be-pocketbase-volume` for details.

## Docker Compose (for my scenario, only the Pocketbase part)

I called the container `be-pocketbase`, the `be-` means `back-end`, just for my personal convention.

```
services:
  be-pocketbase:
    container_name: be-pocketbase
    build: .
    image: be-pocketbase:latest
    volumes:
      - be-pocketbase-volume:/app/pocketbase/pb_data
    networks:
      - my-network

networks:
  my-network:
    name: my-network
    external: true

volumes:
  be-pocketbase-volume:
    name: be-pocketbase-volume
    external: true
```

Run it with `docker compose up -d`. Just `docker inspect be-pocketbase` for details. At this point I already can run Pocketbase on https://pocketbase.xxx.xxx or https://pocketbase.xxx.xxx/_/ for the admin page.

## Docker Compose (typical scenario, for general purpose)

This is for you that need to quickly spin up Pocketbase and run on localhost.

```
services:
  be-pocketbase:
    container_name: be-pocketbase
    build: .
    image: be-pocketbase:latest
    volumes:
      - be-pocketbase-volume:/app/pocketbase/pb_data
    networks:
      - my-network
    ports:
      - "8090:8090"

networks:
  my-network:
    name: my-network
    external: true

volumes:
  be-pocketbase-volume:
    name: be-pocketbase-volume
    external: true
```

Run it with `docker compose up -d`. Just `docker inspect be-pocketbase` for details. At this point I already can run Pocketbase on http://localhost:8090/ or http://localhost:8090/_/ for the admin page.

## Nginx config (my scenario, reverse proxy use case)

I setup reverse proxy using Nginx. Nginx is also a container and traffic comes from Cloudflare DNS. As you can see the Pocketbase is on subdomain pocketbase.xxx.xxx and the `proxy_pass` will point to Pocketbase container (`be-pocketbase` in this case).

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

Thank you for the great piece of software called [Pocketbase](https://github.com/pocketbase/pocketbase) created by https://github.com/ganigeorgiev.
