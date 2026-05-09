package services

import (
"errors"
"os"
"time"

"github.com/golang-jwt/jwt/v5"
"github.com/google/uuid"
"github.com/uruuz/uruuz-backend/internal/db"
"github.com/uruuz/uruuz-backend/internal/models"
"golang.org/x/crypto/bcrypt"
)

type AuthService struct{}

func NewAuthService() *AuthService {
return &AuthService{}
}

func (s *AuthService) Signup(firstName, lastName, email, phone, pin string) (*models.User, error) {
// Hash PIN
hashedPin, err := bcrypt.GenerateFromPassword([]byte(pin), bcrypt.DefaultCost)
if err != nil {
return nil, err
}

user := models.User{
FirstName: firstName,
LastName:  lastName,
Email:     email,
Phone:     phone,
Pin:       string(hashedPin),
}

// Start transaction to create user and wallet
tx := db.DB.Begin()
if err := tx.Create(&user).Error; err != nil {
tx.Rollback()
return nil, err
}

wallet := models.Wallet{
UserID:   user.ID,
Currency: "UGX",
Balance:  0,
}
if err := tx.Create(&wallet).Error; err != nil {
tx.Rollback()
return nil, err
}

if err := tx.Commit().Error; err != nil {
return nil, err
}

user.Wallet = wallet
return &user, nil
}

func (s *AuthService) Login(phone, pin string) (string, *models.User, error) {
var user models.User
if err := db.DB.Preload("Wallet").Where("phone = ?", phone).First(&user).Error; err != nil {
return "", nil, errors.New("invalid phone or PIN")
}

// Check PIN
if err := bcrypt.CompareHashAndPassword([]byte(user.Pin), []byte(pin)); err != nil {
return "", nil, errors.New("invalid phone or PIN")
}

// Generate JWT
token, err := s.GenerateToken(user.ID)
if err != nil {
return "", nil, err
}

return token, &user, nil
}

func (s *AuthService) GenerateToken(userID uuid.UUID) (string, error) {
secret := os.Getenv("JWT_SECRET")
if secret == "" {
secret = "uruuz_secret_key_change_me"
}

claims := jwt.MapClaims{
"user_id": userID.String(),
"exp":     time.Now().Add(time.Hour * 72).Unix(),
}

token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
return token.SignedString([]byte(secret))
}

func (s *AuthService) ValidateToken(tokenString string) (uuid.UUID, error) {
secret := os.Getenv("JWT_SECRET")
if secret == "" {
secret = "uruuz_secret_key_change_me"
}

token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
return []byte(secret), nil
})

if err != nil || !token.Valid {
return uuid.Nil, errors.New("invalid token")
}

claims, ok := token.Claims.(jwt.MapClaims)
if !ok {
return uuid.Nil, errors.New("invalid claims")
}

userIDStr, ok := claims["user_id"].(string)
if !ok {
return uuid.Nil, errors.New("user_id not found in token")
}

userID, err := uuid.Parse(userIDStr)
if err != nil {
return uuid.Nil, err
}

return userID, nil
}
