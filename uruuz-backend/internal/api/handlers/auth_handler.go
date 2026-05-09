package handlers

import (
"net/http"

"github.com/gin-gonic/gin"
"github.com/uruuz/uruuz-backend/internal/services"
)

type AuthHandler struct {
authService *services.AuthService
}

func NewAuthHandler() *AuthHandler {
return &AuthHandler{
authService: services.NewAuthService(),
}
}

type SignupRequest struct {
FirstName string `json:"first_name" binding:"required"`
LastName  string `json:"last_name" binding:"required"`
Email     string `json:"email" binding:"required,email"`
Phone     string `json:"phone" binding:"required"`
Pin       string `json:"pin" binding:"required,len=6"`
}

func (h *AuthHandler) Signup(c *gin.Context) {
var req SignupRequest
if err := c.ShouldBindJSON(&req); err != nil {
c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
return
}

user, err := h.authService.Signup(req.FirstName, req.LastName, req.Email, req.Phone, req.Pin)
if err != nil {
c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
return
}

c.JSON(http.StatusCreated, user)
}

type LoginRequest struct {
Phone string `json:"phone" binding:"required"`
Pin   string `json:"pin" binding:"required"`
}

func (h *AuthHandler) Login(c *gin.Context) {
var req LoginRequest
if err := c.ShouldBindJSON(&req); err != nil {
c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
return
}

token, user, err := h.authService.Login(req.Phone, req.Pin)
if err != nil {
c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
return
}

c.JSON(http.StatusOK, gin.H{
"token": token,
"user":  user,
})
}
