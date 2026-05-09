package handlers

import (
"net/http"

"github.com/gin-gonic/gin"
"github.com/google/uuid"
"github.com/uruuz/uruuz-backend/internal/services"
)

var walletService = services.NewWalletService()

func GetBalance(c *gin.Context) {
userIDStr := c.Param("user_id")
userID, err := uuid.Parse(userIDStr)
if err != nil {
c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user id"})
return
}

wallet, err := walletService.GetWalletByUserID(userID)
if err != nil {
c.JSON(http.StatusNotFound, gin.H{"error": "wallet not found"})
return
}

c.JSON(http.StatusOK, gin.H{
"balance":  wallet.Balance,
"currency": wallet.Currency,
})
}

func GetHistory(c *gin.Context) {
userIDStr := c.Param("user_id")
userID, err := uuid.Parse(userIDStr)
if err != nil {
c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user id"})
return
}

wallet, err := walletService.GetWalletByUserID(userID)
if err != nil {
c.JSON(http.StatusNotFound, gin.H{"error": "wallet not found"})
return
}

history, err := walletService.GetTransactionHistory(wallet.ID)
if err != nil {
c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch history"})
return
}

c.JSON(http.StatusOK, history)
}

type TransferRequest struct {
ReceiverUserID uuid.UUID `json:"receiver_user_id" binding:"required"`
Amount         int64     `json:"amount" binding:"required,gt=0"`
Description    string    `json:"description"`
}

func P2PTransfer(c *gin.Context) {
senderUserIDStr := c.Param("user_id")
senderUserID, err := uuid.Parse(senderUserIDStr)
if err != nil {
c.JSON(http.StatusBadRequest, gin.H{"error": "invalid sender user id"})
return
}

var req TransferRequest
if err := c.ShouldBindJSON(&req); err != nil {
c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
return
}

err = walletService.Transfer(senderUserID, req.ReceiverUserID, req.Amount, req.Description)
if err != nil {
c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
return
}

c.JSON(http.StatusOK, gin.H{"message": "transfer successful"})
}
