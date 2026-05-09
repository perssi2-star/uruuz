package db

import (
"context"
"fmt"
"os"

"github.com/redis/go-redis/v9"
)

var RedisClient *redis.Client
var Ctx = context.Background()

func InitRedis() {
host := os.Getenv("REDIS_HOST")
if host == "" {
host = "localhost"
}
port := os.Getenv("REDIS_PORT")
if port == "" {
port = "6379"
}

RedisClient = redis.NewClient(&redis.Options{
Addr:     fmt.Sprintf("%s:%s", host, port),
Password: "", // no password set
DB:       0,  // use default DB
})

_, err := RedisClient.Ping(Ctx).Result()
if err != nil {
fmt.Printf("Could not connect to Redis: %v\n", err)
} else {
fmt.Println("Connected to Redis successfully")
}
}
