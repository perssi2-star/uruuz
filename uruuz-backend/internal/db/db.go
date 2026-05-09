package db

import (
    "fmt"
    "log"
    "os"

    "gorm.io/driver/postgres"
    "gorm.io/gorm"
    "github.com/uruuz/uruuz-backend/internal/models"
)

var DB *gorm.DB

func InitDB() {
    dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%s sslmode=disable TimeZone=UTC",
        os.Getenv("DB_HOST"),
        os.Getenv("DB_USER"),
        os.Getenv("DB_PASSWORD"),
        os.Getenv("DB_NAME"),
        os.Getenv("DB_PORT"),
    )
    db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
    if err != nil {
        log.Fatalf("failed to connect database: %v", err)
    }

    DB = db
    fmt.Println("Database connection established")

    // Run Migrations
    err = db.AutoMigrate(&models.User{}, &models.Wallet{}, &models.Transaction{}, &models.KYC{})
    if err != nil {
        log.Fatalf("failed to run migrations: %v", err)
    }
    fmt.Println("Database migrations completed")
}
