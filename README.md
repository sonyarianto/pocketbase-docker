# pocketbase-docker

Dockerized [Pocketbase](https://github.com/pocketbase/pocketbase), based on:

- https://github.com/krushiraj/pocketbase-docker/blob/main/Dockerfile
- https://github.com/bscott/pocketbase-docker/blob/main/Dockerfile
- https://github.com/muchobien/pocketbase-docker

Basically it just for my personal use case scenario.

Credits to [Gani Georgiev](https://github.com/ganigeorgiev) who created Pocketbase, it's great piece of software.

## Notes

- Read the `Dockerfile`. That's the core file to build the image.
- Pocketbase will expose port `8090` inside the container.
- Update `POCKETBASE_VERSION` on `Dockerfile` to the latest version. See the latest version number at at https://github.com/pocketbase/pocketbase/releases. I will try to update the version number as often as I can.

## Docker Compose (typical scenario, for general purpose)

This is for you that need to quickly spin up Pocketbase and run on localhost. You can adjust it. As you can see, I define `networks` and `volumes` to make data persistent if you stop the container.

```
version: '3.8'

services:
  pocketbase:
    container_name: pocketbase
    build: .
    image: pocketbase:latest
    volumes:
      - pocketbase-volume:/app/data
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

Run it with `docker compose up -d`. At this point we already can run Pocketbase on http://localhost:8090/.
- Admin page go to http://localhost:8090/_/
- API URI on the http://localhost:8090/api/

Run `docker inspect pocketbase` for more details.

If you don't want to expose the port, just remove or comment the `ports` section above.

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

## License

MIT

Maintained by Sony Arianto Kurniawan <<sony@sony-ak.com>> and contributors.
