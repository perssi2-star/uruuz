package middleware

import (
"fmt"
"net/http"
"time"

"github.com/gin-gonic/gin"
"github.com/uruuz/uruuz-backend/internal/db"
)

func RateLimitMiddleware() gin.HandlerFunc {
return func(c *gin.Context) {
key := fmt.Sprintf("ratelimit:%s", c.ClientIP())

val, err := db.RedisClient.Incr(db.Ctx, key).Result()
if err != nil {
c.Next() // Fallback if redis is down
return
}

if val == 1 {
db.RedisClient.Expire(db.Ctx, key, time.Minute)
}

if val > 60 { // 60 requests per minute
c.JSON(http.StatusTooManyRequests, gin.H{"error": "Rate limit exceeded"})
c.Abort()
return
}

c.Next()
}
}
