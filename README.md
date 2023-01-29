# pocketbase-docker

## What is this?

Dockerized Pocketbase (https://github.com/pocketbase/pocketbase), based on:

- https://github.com/krushiraj/pocketbase-docker/blob/main/Dockerfile
- https://github.com/bscott/pocketbase-docker/blob/main/Dockerfile.

Basically it just for my personal use case scenario.

## Notes

- Read the `Dockerfile`.
- Pocketbase expose port `8090` on container.
- Please update `POCKETBASE_VERSION` on `Dockerfile` to the latest version. See the latest version number at at https://github.com/pocketbase/pocketbase/releases. I will try to update the version number as often as I can.

## Docker Compose (typical scenario, for general purpose)

This is for you that need to quickly spin up Pocketbase and run on localhost. You can adjust it. As you can see, I define `networks` and `volumes` to make data persistent if you stop the container.

```
services:
  pocketbase:
    container_name: pocketbase
    build: .
    image: pocketbase:latest
    volumes:
      - pocketbase-volume:/app/pocketbase/pb_data
    networks:
      - my-network
    ports:
      - "8090:8090"

networks:
  my-network:
    name: my-network

volumes:
  pocketbase-volume:
    name: pocketbase-volume
```

Run it with `docker compose up -d`. At this point we already can run Pocketbase on http://localhost:8090/ or http://localhost:8090/_/ for the admin page. Just run `docker inspect pocketbase` for more details.

## My scenario (my prefered flow)

- I have dedicated hosting with public IP address. This dedicated hosting will run all of my Docker containers.
- I have Cloudflare DNS to manage my domain.
- I already pointing subdomain pocketbase.xxxx.xxx to my public IP.
- I setup Nginx as a container
- I setup Pocketbase as a container.
- I setup server_name on Nginx and do reverse proxy to Pocketbase container.
- Pocketbase container exposed the port internally, not to host.
- Pocketbase data saved on Docker volume so it will not gone when container removed. Just `docker inspect pocketbase-volume` for details.

## Docker Compose (for my scenario, only the Pocketbase part)

```
services:
  pocketbase:
    container_name: pocketbase
    build: .
    image: pocketbase:latest
    volumes:
      - pocketbase-volume:/app/pocketbase/pb_data
    networks:
      - my-network

networks:
  my-network:
    name: my-network

volumes:
  pocketbase-volume:
    name: pocketbase-volume
```

Run it with `docker compose up -d`. At this point I already can run Pocketbase on https://pocketbase.xxx.xxx or https://pocketbase.xxx.xxx/_/ for the admin page. Just `docker inspect pocketbase` for more details.

## Nginx config (my scenario, reverse proxy use case)

```
server {
  listen 443 ssl http2;
  listen [::]:443 ssl http2;

  listen 80;
  listen [::]:80;

  server_name pocketbase.xxxx.xxx; # a subdomain

  location / {
    proxy_set_header Connection '';
    proxy_http_version 1.1;
    proxy_read_timeout 180s;

    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;

    proxy_pass http://pocketbase:8090;
  }

  ssl_certificate /just_example_of_selfsigned.crt;
  ssl_certificate_key /just_example_of_selfsigned.key;
}
```

Thank you for the great piece of software called [Pocketbase](https://github.com/pocketbase/pocketbase) created by https://github.com/ganigeorgiev.
