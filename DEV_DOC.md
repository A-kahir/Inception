# Developer Documentation
This document explains how a developer can set up, build, and work on the Inception project from scratch, and how the project's data is organized and persisted.

## Setting up the environment from scratch

### Prerequisites
- A Linux virtual machine.
- Docker and Docker Compose installed.
- A domain name pointing to the machine's local IP address, following the `login.42.fr` format. In this project the domain used is `akahir.42.fr`, added to `/etc/hosts` on the machine used to browse the site.

### Configuration files
The project's configuration lives entirely under `srcs`:
```
.
├── docker-compose.yml
└── requirements
    ├── mariadb
    │   ├── Dockerfile
    │   └── tools
    │       └── entrypoint.sh
    ├── nginx
    │   ├── conf
    │   │   └── nginx.conf
    │   ├── dockerfile
    │   └── tools
    │       ├── entrypoint.sh
    │       └── generate-certificate.sh
    └── wordpress
        ├── Dockerfile
        └── tools
            └── entrypoint.sh

```

Before starting the project, create and fill in `srcs/.env` with the required variables:
- `DOMAIN_NAME`- the domain name of the site (`akahir.42.fr`).
- `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD`, `MYSQL_ROOT_PASSWORD`- database configuration.
- `WP_URL`, `WP_TITLE`- WordPress site settings.
- `WP_ADMIN_USER`, `WP_ADMIN_PASSWORD`, `WP_ADMIN_EMAIL`- WordPress administrator account.
- Credentials for the second WordPress user.

This file must never be committed to Git. Sensitive values should ideally be handled through Docker secrets rather than plain environment variables where possible, and any credentials must stay out of the Git history entirely.

## Building and launching the project
Everything is driven by the `Makefile` at the root of the repository, which wraps `docker compose -f srcs/docker-compose.yml`.

- Build the images and start every container:
  ```
  make
  ```
- Build the images without starting the containers:
  ```
  make build
  ```
- Start already-built containers:
  ```
  make up
  ```
- Remove containers only:
  ```
  make clean
  ```
- Remove containers, volumes, and images, then prune the Docker system:
  ```
  make fclean
  ```
- Full rebuild from a clean state:
  ```
  make re
  ```

Each service (`mariadb`, `wordpress`, `nginx`) is built from its own Dockerfile, based on Debian, and is named after its service so the image names match the service names in `docker-compose.yml`.

## Managing containers and volumes
Useful Docker Compose commands, run from the repository root:
- List running containers and their status:
  ```
  docker compose -f srcs/docker-compose.yml ps
  ```
- Follow logs of a specific service:
  ```
  docker compose -f srcs/docker-compose.yml logs -f <service_name>
  ```
- Open a shell inside a running container:
  ```
  docker compose -f srcs/docker-compose.yml exec <service_name> bash
  ```
- List Docker volumes:
  ```
  docker volume ls
  ```
- Inspect a volume to see where it is mounted:
  ```
  docker volume inspect <volume_name>
  ```

## Where data is stored and how it persists
Two named volumes are defined in `docker-compose.yml`:
- `mariadb_data`, mounted at `/var/lib/mysql` inside the MariaDB container, storing the WordPress database.
- `wordpress_data`, mounted at `/var/www/html` inside both the WordPress and NGINX containers, storing the WordPress website files.

Both volumes use the `local` driver with bind-style `driver_opts`, pointing to fixed paths on the host machine:
- `/home/akahir/data/mariadb`
- `/home/akahir/data/wordpress`

Because these are named volumes rather than plain bind mounts, Docker manages their lifecycle directly while still keeping the underlying data at a predictable location on the host. This means the data survives container removal and rebuilds (`make down`, `make re`).