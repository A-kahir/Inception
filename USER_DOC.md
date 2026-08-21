# User Documentation
This document explains how to use the Inception stack once it has been deployed on the virtual machine.
It is aimed at end users and administrators who need to run the project, reach the website, and check that everything is working, without going into the technical details of how it was built.

## Services provided by the stack
The stack is made of three services working together:

- **NGINX**- the only entry point of the infrastructure. It serves the website over HTTPS on port 443 and forwards PHP requests to the WordPress service.
- **WordPress (with php-fpm)**- the content management system that powers the website, including its administration panel.
- **MariaDB**- the database that stores all WordPress content (pages, posts, users, settings).

These three services run in separate containers and are only reachable from each other through an internal Docker network.

## Starting and stopping the project
All actions are done from the root of the repository, on the virtual machine.
- Start the project (builds the images if needed and starts every container):
  ```
  make
  ```
- Stop the containers without removing them:
  ```
  make stop
  ```
- Start containers that were previously stopped:
  ```
  make start
  ```
- Stop and remove the containers:
  ```
  make down
  ```
- Remove containers, images, and volumes entirely, then rebuild from scratch:
  ```
  make re
  ```

## Accessing the website and the administration panel
Once the containers are running, the website is available at:
```
https://akahir.42.fr
```
Since the certificate used by NGINX is self-signed, the browser will show a security warning the first time you visit the site. This is expected; you can safely proceed.

The WordPress administration panel is available at:
```
https://akahir.42.fr/wp-admin
```
Log in with one of the WordPress accounts described below.

## Locating and managing credentials
Credentials used by the stack (database name, database user and password, WordPress admin and user accounts) are defined as environment variables in the `.env` file located in the `srcs` folder. This file is not tracked by Git and must be filled in locally before starting the project.

There are two WordPress accounts by default:
- An administrator account, whose username does not contain "admin"for security reasons.
- A second, regular user account with more limited permissions.

If a password needs to be changed, update the corresponding value in `.env` and recreate the affected container so the new value is taken into account.

## Checking that the services are running correctly
To see the status of all containers:
```
docker compose -f srcs/docker-compose.yml ps
```

Every service should appear with a status of `Up`. If a container keeps restarting or shows an `Exit` status, check its logs:
```
docker compose -f srcs/docker-compose.yml logs <service_name>
```

replacing `<service_name>` with `mariadb`, `wordpress`, or `nginx`.

You can also confirm the website is reachable by opening `https://akahir.42.fr` in a browser and verifying that the homepage loads, and that you can log in to `https://akahir.42.fr/wp-admin` with the administrator credentials.
