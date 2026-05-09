package handlers

import (
"net/http"

"github.com/gin-gonic/gin"
"github.com/google/uuid"
"github.com/uruuz/uruuz-backend/internal/services"
)

type PaymentHandler struct {
paymentService *services.PaymentService
}

func NewPaymentHandler() *PaymentHandler {
return &PaymentHandler{
paymentService: services.NewPaymentService(),
}
}

type MoMoCollectRequest struct {
Amount int64  `json:"amount" binding:"required"`
Phone  string `json:"phone" binding:"required"`
}

func (h *PaymentHandler) MoMoCollect(c *gin.Context) {
userIDStr := c.GetString("user_id")
if userIDStr == "" {
userIDStr = c.Param("user_id")
}

userID, err := uuid.Parse(userIDStr)
if err != nil {
c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user id"})
return
}

var req MoMoCollectRequest
if err := c.ShouldBindJSON(&req); err != nil {
c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
return
}

ref, err := h.paymentService.CollectFromMoMo(userID, req.Amount, req.Phone)
if err != nil {
c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
return
}

c.JSON(http.StatusAccepted, gin.H{"reference_id": ref})
}

type MoMoDisburseRequest struct {
Amount int64  `json:"amount" binding:"required"`
Phone  string `json:"phone" binding:"required"`
}

func (h *PaymentHandler) MoMoDisburse(c *gin.Context) {
userIDStr := c.GetString("user_id")
if userIDStr == "" {
userIDStr = c.Param("user_id")
}

userID, err := uuid.Parse(userIDStr)
if err != nil {
c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user id"})
return
}

var req MoMoDisburseRequest
if err := c.ShouldBindJSON(&req); err != nil {
c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
return
}

ref, err := h.paymentService.DisburseToMoMo(userID, req.Amount, req.Phone)
if err != nil {
c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
return
}

c.JSON(http.StatusAccepted, gin.H{"reference_id": ref})
}

func (h *PaymentHandler) MoMoStatus(c *gin.Context) {
ref := c.Param("ref")
if ref == "" {
c.JSON(http.StatusBadRequest, gin.H{"error": "reference id is required"})
return
}

tx, err := h.paymentService.CheckMoMoStatus(ref)
if err != nil {
c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
return
}

c.JSON(http.StatusOK, tx)
}
