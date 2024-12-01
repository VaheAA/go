# Load environment variables from .env file
include .env
export $(shell sed 's/=.*//' .env)

.PHONY: postgres createdb dropdb migrateup migratedown sqlc test server

postgres:
	docker run --name postgres_lts -p 5432:5432 -e POSTGRES_USER=$(POSTGRES_USER) -e POSTGRES_PASSWORD=$(POSTGRES_PASSWORD) -d postgres

createdb:
	docker exec -it postgres_lts createdb --username=$(POSTGRES_USER) --owner=$(POSTGRES_USER) simple_bank

dropdb:
	docker exec -it postgres_lts dropdb simple_bank

migrateup: 
	migrate --path db/migration --database "postgres://$(POSTGRES_USER):$(POSTGRES_PASSWORD)@localhost:5432/simple_bank?sslmode=disable" --verbose up

migratedown:
	migrate --path db/migration --database "postgres://$(POSTGRES_USER):$(POSTGRES_PASSWORD)@localhost:5432/simple_bank?sslmode=disable" --verbose down

sqlc:
	sqlc generate	

test:
	go test -v -cover ./...		

server: 
	go run main.go