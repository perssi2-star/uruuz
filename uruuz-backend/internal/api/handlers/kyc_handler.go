package handlers

import (
"net/http"

"github.com/gin-gonic/gin"
"github.com/google/uuid"
"github.com/uruuz/uruuz-backend/internal/services"
)

type KYCHandler struct {
kycService *services.KYCService
}

func NewKYCHandler() *KYCHandler {
return &KYCHandler{
kycService: services.NewKYCService(),
}
}

type VerifyNINRequest struct {
NIN string `json:"nin" binding:"required"`
}

func (h *KYCHandler) VerifyNIN(c *gin.Context) {
userIDStr := c.GetString("user_id")
if userIDStr == "" {
userIDStr = c.Param("user_id")
}

userID, err := uuid.Parse(userIDStr)
if err != nil {
c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user id"})
return
}

var req VerifyNINRequest
if err := c.ShouldBindJSON(&req); err != nil {
c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
return
}

kyc, err := h.kycService.VerifyNIN(userID, req.NIN)
if err != nil {
c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
return
}

c.JSON(http.StatusOK, kyc)
}

type VerifyFaceRequest struct {
Selfie string `json:"selfie" binding:"required"` // Base64
}

func (h *KYCHandler) VerifyFace(c *gin.Context) {
userIDStr := c.GetString("user_id")
if userIDStr == "" {
userIDStr = c.Param("user_id")
}

userID, err := uuid.Parse(userIDStr)
if err != nil {
c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user id"})
return
}

var req VerifyFaceRequest
if err := c.ShouldBindJSON(&req); err != nil {
c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
return
}

kyc, err := h.kycService.VerifyFace(userID, req.Selfie)
if err != nil {
c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
return
}

c.JSON(http.StatusOK, kyc)
}

func (h *KYCHandler) GetStatus(c *gin.Context) {
userIDStr := c.GetString("user_id")
if userIDStr == "" {
userIDStr = c.Param("user_id")
}

userID, err := uuid.Parse(userIDStr)
if err != nil {
c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user id"})
return
}

kyc, err := h.kycService.GetKYCStatus(userID)
if err != nil {
c.JSON(http.StatusNotFound, gin.H{"error": "KYC record not found"})
return
}

c.JSON(http.StatusOK, kyc)
}
