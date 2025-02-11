.PHONY: postgres createdb dropdb migrateup migratedown sqlc test server mock

postgres:
	docker run --name postgres_lts -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=root -d postgres

createdb:
	docker exec -it postgres_lts createdb --username=root --owner=root simple_bank

dropdb:
	docker exec -it postgres_lts dropdb simple_bank

migrateup: 
	migrate --path db/migration --database "postgres://root:root@localhost:5432/simple_bank?sslmode=disable" --verbose up

migratedown:
	migrate --path db/migration --database "postgres://root:root@localhost:5432/simple_bank?sslmode=disable" --verbose down

sqlc:
	sqlc generate	

test:
	go test -v -cover ./...		

server: 
	go run main.go

mock:
	 mockgen -package mockdb --destination db/mock/store.go simplebank/db/sqlc Store	