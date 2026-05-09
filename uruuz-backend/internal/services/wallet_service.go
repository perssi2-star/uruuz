package services

import (
"errors"
"fmt"
"time"

"github.com/google/uuid"
"github.com/uruuz/uruuz-backend/internal/db"
"github.com/uruuz/uruuz-backend/internal/models"
"gorm.io/gorm"
"gorm.io/gorm/clause"
)

type WalletService struct{}

func NewWalletService() *WalletService {
return &WalletService{}
}

func (s *WalletService) Transfer(senderUserID, receiverUserID uuid.UUID, amount int64, description string) error {
if amount <= 0 {
return errors.New("amount must be positive")
}
if senderUserID == receiverUserID {
return errors.New("cannot transfer to self")
}

return db.DB.Transaction(func(tx *gorm.DB) error {
var senderWallet models.Wallet
if err := tx.Clauses(clause.Locking{Strength: "UPDATE"}).Where("user_id = ?", senderUserID).First(&senderWallet).Error; err != nil {
return fmt.Errorf("sender wallet not found: %w", err)
}

if senderWallet.Balance < amount {
return errors.New("insufficient balance")
}

var receiverWallet models.Wallet
if err := tx.Clauses(clause.Locking{Strength: "UPDATE"}).Where("user_id = ?", receiverUserID).First(&receiverWallet).Error; err != nil {
return fmt.Errorf("receiver wallet not found: %w", err)
}

// Update balances
senderWallet.Balance -= amount
if err := tx.Save(&senderWallet).Error; err != nil {
return err
}

receiverWallet.Balance += amount
if err := tx.Save(&receiverWallet).Error; err != nil {
return err
}

// Create transaction record
reference := fmt.Sprintf("P2P-%d", time.Now().UnixNano())
transaction := models.Transaction{
SenderWalletID:   &senderWallet.ID,
ReceiverWalletID: &receiverWallet.ID,
Amount:           amount,
Type:             models.TxTypeTransfer,
Status:           models.TxStatusCompleted,
Reference:        reference,
Description:      description,
}

if err := tx.Create(&transaction).Error; err != nil {
return err
}

return nil
})
}

func (s *WalletService) GetWalletByUserID(userID uuid.UUID) (*models.Wallet, error) {
var wallet models.Wallet
if err := db.DB.Where("user_id = ?", userID).First(&wallet).Error; err != nil {
return nil, err
}
return &wallet, nil
}

func (s *WalletService) GetTransactionHistory(walletID uuid.UUID) ([]models.Transaction, error) {
var transactions []models.Transaction
if err := db.DB.Where("sender_wallet_id = ? OR receiver_wallet_id = ?", walletID, walletID).
Order("created_at desc").Find(&transactions).Error; err != nil {
return nil, err
}
return transactions, nil
}
