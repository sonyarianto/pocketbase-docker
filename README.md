# pocketbase-docker

Dockerized [Pocketbase](https://github.com/pocketbase/pocketbase).

## Technical Notes

The most important file is `Dockerfile` that define the image and later for build the image purpose, and there is `docker-compose.yml` to make it easy to run or build with Docker Compose.

- Read the `Dockerfile`. That's the core file to build the image.
- Pocketbase will expose port `8090` inside the container (as defined on `Dockerfile` file).
- Pocketbase will use volume called `pocketbase-volume` for data persistent storage (as defined in `docker-compose.yml`).
- Pocketbase will use `/app/data/pb_data` to store data and `/app/data/pb_public` to store data that public facing to users, such as HTML, CSS, images, JS etc. 
- Update `POCKETBASE_VERSION` on `Dockerfile` to the latest version. See the latest version number at at https://github.com/pocketbase/pocketbase/releases. I will try to update the version number as often as I can.

## Docker Compose (typical scenario)

This is for you that need to quickly spin up Pocketbase and run on your host (localhost or on cloud). You can adjust it. As you can see, I define `volumes` to make data persistent if you stop the container.

```
services:
  pocketbase:
    container_name: pocketbase
    build: .
    image: pocketbase:latest
    volumes:
      - pocketbase-volume:/app/data
    ports:
      - "8090:8090"

volumes:
  pocketbase-volume:
    name: pocketbase-volume
```

Run it with `docker compose up -d`. At this point we already can run Pocketbase on http://localhost:8090/.
- Admin page go to http://localhost:8090/_/
- API URI on the http://localhost:8090/api/

Run `docker inspect pocketbase` for more details.

If you don't want to expose the port to host, just remove or comment the `ports` section above.

## Nginx config (using reverse proxy)

Let say you have domain `example.com` and you already create subdomain `api.example.com` to server your Pocketbase infrastructure. I assume you already setup the SSL certificate as well (I am using Cloudflare DNS so SSL is already provided).

```
server {
  listen 80;
  listen [::]:80;
  
  server_name api.example.com; # adjust this to your domain

  return 301 https://api.example.com$request_uri; # adjust this to your URI
}

server {
  listen 443 ssl;
  listen [::]:443 ssl;

  server_name api.example.com; # adjust this to your domain

  location / {
    proxy_set_header Connection '';
    proxy_http_version 1.1;
    proxy_read_timeout 180s;

    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-By $remote_addr;

    proxy_pass http://pocketbase:8090; # this is pointing to service name on the Docker Compose, adjust it when necessary
  }

  ssl_certificate /just_example_of_selfsigned.crt; # adjust this with your situation
  ssl_certificate_key /just_example_of_selfsigned.key; # adjust this with your situation
}
```

At this point you will have Pocketbase on https://api.example.com

Remember https://api.example.com/_/ to access the Admin page and https://api.example.com/api/ is the API endpoint.

## Nginx config (using reverse proxy and using base path)

This scenario will assume you have URL https://api.example.com/ (similar like previous Nginx scenario) but the Pocketbase will be on the base path called `pocketbase` so the end result will be like https://api.example.com/pocketbase

```
server {
  listen 80;
  listen [::]:80;
  
  server_name api.example.com; # adjust this to your domain

  return 301 https://api.example.com$request_uri; # adjust this to your URI
}

server {
  listen 443 ssl;
  listen [::]:443 ssl;

  server_name api.example.com; # adjust this to your domain

  location /pocketbase { # adjust this base path when necessary
    rewrite /pocketbase/(.*) /$1  break; # adjust this rewrite when necessary

    proxy_set_header Connection '';
    proxy_http_version 1.1;
    proxy_read_timeout 180s;

    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-By $remote_addr;

    proxy_pass http://pocketbase:8090; # this is pointing to service name on the Docker Compose, adjust it when necessary
  }

  ssl_certificate /your_path_to_ssl_files/just_example_of_selfsigned.crt; # adjust this with your situation
  ssl_certificate_key /your_path_to_ssl_files/just_example_of_selfsigned.key; # adjust this with your situation
}
```

At this point you will have Pocketbase on https://api.example.com/pocketbase

Remember https://api.example.com/pocketbase/_/ to access the Admin page and https://api.example.com/pocketbase/api/ is the API endpoint.

## Questions

If you still have any question please feel free to write to me on Discussions section above.

## Credits

Inspired and based on:

- https://github.com/krushiraj/pocketbase-docker/blob/main/Dockerfile
- https://github.com/bscott/pocketbase-docker/blob/main/Dockerfile
- https://github.com/muchobien/pocketbase-docker
- https://github.com/pocketbase/pocketbase/issues/92

Credits to [Gani Georgiev](https://github.com/ganigeorgiev) who created Pocketbase, it's great piece of software.

## License

MIT

Maintained by Sony Arianto Kurniawan <<sony@sony-ak.com>> and contributors.
