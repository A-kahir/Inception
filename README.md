*This project has been created as part of the 42 curriculum by akahir.*

# Inception

## Description

Inception is a system administration project that consists of building a small, containerized web infrastructure using Docker and Docker Compose. The goal is to understand how to package and orchestrate several services so that they run in isolated, dedicated containers while still being able to communicate with each other.

The infrastructure is made of three services, each built from its own Dockerfile on top of Debian:

- **NGINX**, configured, acting as the single entry point of the whole infrastructure on port 443.
- **WordPress with php-fpm**, running the website itself without any web server bundled in.
- **MariaDB**, storing the WordPress database without any web server bundled in.

Two named volumes persist data across restarts: one for the WordPress database and one for the WordPress website files. All containers communicate through a dedicated Docker network, and none of them are reachable directly from outside except NGINX.

## Instructions

### Requirements

- A Linux virtual machine with Docker and Docker Compose installed.
- A domain name pointing to the machine's local IP address, following the `login.42.fr` format (in this project, `akahir.42.fr`).

### Setup

1. Clone the repository on the virtual machine.
2. Add an entry in `/etc/hosts` so that `akahir.42.fr` resolves to the machine's local IP address.
3. Fill in the `.env` file at the root of `srcs` with the required environment variables (domain name, database name, database user and password, WordPress admin and user credentials).
4. From the root of the repository, run:

```
make
```

This builds every Docker image and starts the containers in detached mode.

### Useful commands

- `make up`- start the containers without rebuilding.
- `make clean`- stop and remove the containers.
- `make fclean`- remove containers, volumes, images, and prune the Docker system.
- `make re`- full clean followed by a fresh build and start.
Once the containers are up, the website is reachable at `https://akahir.42.fr`.

## Resources
- Docker: https://www.geeksforgeeks.org/devops/introduction-to-docker/
- 42 Inception subject and internal school documentation + Ai.

AI assistance was used during this project to help debug (in particular the MariaDB initialization sequence and the WordPress installation flow through WP-CLI), to clarify how PID 1 and process signals behave inside a container, and to review the docker-compose.yml file for mistakes..and explain eny diff between concepts and types and the architecutre of docker how execute the command and how they create and intial a container + network and environement...

## Project description

### Docker and sources organization
The project is split into a `srcs` folder containing the `docker-compose.yml` file, the `.env` file, and a `requirements` folder holding one subfolder per service (`mariadb`, `nginx`, `wordpress`). Each service subfolder contains its own `Dockerfile`, its configuration files under `conf`, and its startup scripts under `tools`. The `Makefile` at the root builds and manages the whole stack through Docker Compose. This structure keeps each service self-contained and makes it easy to rebuild or modify one component without affecting the others.

### Virtual Machines vs Docker
=>A virtual machine virtualizes an entire operating system, including its own kernel, which makes it heavier to run and slower to start.
=>Docker containers share the host's kernel and only package the application and its dependencies, which makes them much lighter, faster to start, and easier to reproduce across machines.
For this project, Docker is the right choice because it allows several isolated services (web server, application, database) to run independently on the same machine without the overhead of running a full operating system for each one.

### Secrets vs Environment Variables
Environment variables are convenient for non-sensitive configuration values, such as a domain name or a database name, and are easy to pass into containers through the `.env` file.
environment variables can be exposed through process listings or accidentally logged, which makes them less suitable for sensitive information such as passwords.
Docker secrets, are mounted as files inside the container's filesystem and are not visible in the container's environment, which makes them a safer way to handle credentials such as database and WordPress passwords.

### Docker Network vs Host Network
Using the host network would make containers share the network stack of the host machine directly, exposing all their ports without any isolation and removing the ability to control which service is reachable from outside. A dedicated Docker network, as used in this project, isolates the containers in their own virtual network where they can reach each other by service name while staying invisible to the outside world. Only NGINX exposes a port to the host, which keeps the rest of the infrastructure protected and matches the requirement that NGINX be the single entry point.

### Docker Volumes vs Bind Mounts
Bind mounts link a container path directly to a specific path on the host filesystem, which ties the container closely to the host's directory layout and can lead to permission issues.
Docker named volumes are managed by Docker itself, are decoupled from the host's folder structure, and are easier to back up, migrate, or reattach to a new container.
In this project, named volumes are used to persist the WordPress database and website files under `/home/akahir/data`, ensuring the data survives container restarts or rebuilds while remaining fully managed by Docker.