package middleware

import (
"net/http"
"strings"

"github.com/gin-gonic/gin"
"github.com/uruuz/uruuz-backend/internal/services"
)

func AuthMiddleware() gin.HandlerFunc {
return func(c *gin.Context) {
authHeader := c.GetHeader("Authorization")
if authHeader == "" {
c.JSON(http.StatusUnauthorized, gin.H{"error": "Authorization header is required"})
c.Abort()
return
}

parts := strings.Split(authHeader, " ")
if len(parts) != 2 || parts[0] != "Bearer" {
c.JSON(http.StatusUnauthorized, gin.H{"error": "Authorization header must be Bearer token"})
c.Abort()
return
}

tokenString := parts[1]
authService := services.NewAuthService()
userID, err := authService.ValidateToken(tokenString)
if err != nil {
c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid or expired token"})
c.Abort()
return
}

c.Set("user_id", userID.String())
c.Next()
}
}
