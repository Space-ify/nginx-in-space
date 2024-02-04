.PHONY: build up stop remove

build:
	docker compose build --no-cache

up:
	docker compose up -d

stop:
	docker stop space-nginx

remove:
	docker remove space-nginx
