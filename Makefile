COMPOSE = docker compose -f srcs/docker-compose.yml

all:
	mkdir -p "/home/akahir/data/mariadb"
	mkdir -p "/home/akahir/data/wordpress"
	$(COMPOSE) up -d --build

clean:
	$(COMPOSE) down

fclean:
	$(COMPOSE) down -v --rmi all
	docker system prune -af
	@sudo rm -rf "/home/akahir/data"

re: fclean all

.PHONY: all build up clean fclean re