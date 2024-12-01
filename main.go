package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"
	"simplebank/api"
	db "simplebank/db/sqlc"

	"github.com/joho/godotenv"
	_ "github.com/lib/pq"
)

const (
	dbDriver      = "postgres"
	serverAddress = "0.0.0.0:8080"
)

func ConnectDB(envPath string) (*sql.DB, error) {
	// Load the .env file
	err := godotenv.Load(envPath)
	if err != nil {
		log.Printf("Error loading .env file: %v", err)
		return nil, err
	}

	// Read environment variables
	dbUser := os.Getenv("POSTGRES_USER")
	dbPassword := os.Getenv("POSTGRES_PASSWORD")
	dbHost := os.Getenv("POSTGRES_HOST")
	dbPort := os.Getenv("POSTGRES_PORT")
	dbName := os.Getenv("POSTGRES_DB")

	// Construct the connection string
	dbSource := fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=disable",
		dbUser, dbPassword, dbHost, dbPort, dbName)

	// Open the database connection
	db, err := sql.Open(dbDriver, dbSource)
	if err != nil {
		log.Printf("Failed to connect to database: %v", err)
		return nil, err
	}

	// Test the connection
	err = db.Ping()
	if err != nil {
		log.Printf("Database connection is not alive: %v", err)
		return nil, err
	}

	log.Println("Connected to the database successfully")
	return db, nil
}

func main() {
	conn, err := ConnectDB("./.env")
	if err != nil {
		log.Fatalf("Database connection failed: %v", err)
	}
	defer conn.Close()

	store := db.NewStore(conn)
	server := api.NewServer(store)

	err = server.Start(serverAddress)

	if err != nil {
		log.Fatal("cannot start server:", err)
	}
}
