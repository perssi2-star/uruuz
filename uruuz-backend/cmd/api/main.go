package main

import (
"log"
"os"

"github.com/gin-gonic/gin"
"github.com/joho/godotenv"
"github.com/uruuz/uruuz-backend/internal/api/handlers"
"github.com/uruuz/uruuz-backend/internal/api/middleware"
"github.com/uruuz/uruuz-backend/internal/db"
)

func main() {
// Load .env file
if err := godotenv.Load(); err != nil {
log.Println("No .env file found, using environment variables")
}

// Initialize Database
db.InitDB()
// Initialize Redis
db.InitRedis()

// Initialize Router
router := gin.Default()

// Global Middleware
router.Use(middleware.RateLimitMiddleware())

// Public Routes
router.GET("/health", handlers.HealthCheck)

authHandler := handlers.NewAuthHandler()
authRoutes := router.Group("/auth")
{
authRoutes.POST("/signup", authHandler.Signup)
authRoutes.POST("/login", authHandler.Login)
}

// Protected Routes
protected := router.Group("/")
protected.Use(middleware.AuthMiddleware())
{
walletRoutes := protected.Group("/wallets/:user_id")
{
walletRoutes.GET("/balance", handlers.GetBalance)
walletRoutes.GET("/history", handlers.GetHistory)
walletRoutes.POST("/transfer", handlers.P2PTransfer)
}

kycHandler := handlers.NewKYCHandler()
kycRoutes := protected.Group("/kyc/:user_id")
{
    kycRoutes.POST("/verify-nin", kycHandler.VerifyNIN)
    kycRoutes.POST("/verify-face", kycHandler.VerifyFace)
    kycRoutes.GET("/status", kycHandler.GetStatus)
}

momoHandler := handlers.NewMoMoHandler()
momoRoutes := protected.Group("/payments/momo")
{
    momoRoutes.POST("/collect", momoHandler.Collect)
    momoRoutes.POST("/disburse", momoHandler.Disburse)
    momoRoutes.GET("/status/:ref", momoHandler.Status)
}


// Run Server
port := os.Getenv("PORT")
if port == "" {
port = "8080"
}

if err := router.Run(":" + port); err != nil {
log.Fatalf("could not start server: %v", err)
}
}
