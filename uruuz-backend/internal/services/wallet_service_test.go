package services

import (
    "testing"

    "github.com/stretchr/testify/assert"
    "github.com/uruuz/uruuz-backend/internal/db"
    "github.com/uruuz/uruuz-backend/internal/models"
    "gorm.io/driver/sqlite"
    "gorm.io/gorm"
)

func setupTestDB() {
    testDB, _ := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
    testDB.AutoMigrate(&models.User{}, &models.Wallet{}, &models.Transaction{})
    db.DB = testDB
}

func TestTransfer(t *testing.T) {
    setupTestDB()

    user1 := models.User{FirstName: "Sender", LastName: "User", Email: "sender@test.com", Phone: "256700000001"}
    user2 := models.User{FirstName: "Receiver", LastName: "User", Email: "receiver@test.com", Phone: "256700000002"}

    db.DB.Create(&user1)
    db.DB.Create(&user2)

    wallet1 := models.Wallet{UserID: user1.ID, Balance: 10000, Currency: "UGX"}
    wallet2 := models.Wallet{UserID: user2.ID, Balance: 5000, Currency: "UGX"}

    db.DB.Create(&wallet1)
    db.DB.Create(&wallet2)

    t.Run("Successful Transfer", func(t *testing.T) {
        err := Transfer(user1.ID, user2.ID, 2000, "Test transfer")
        assert.NoError(t, err)

        var w1, w2 models.Wallet
        db.DB.First(&w1, "user_id = ?", user1.ID)
        db.DB.First(&w2, "user_id = ?", user2.ID)

        assert.Equal(t, int64(8000), w1.Balance)
        assert.Equal(t, int64(7000), w2.Balance)

        var tx models.Transaction
        err = db.DB.First(&tx, "sender_wallet_id = ? AND receiver_wallet_id = ?", wallet1.ID, wallet2.ID).Error
        assert.NoError(t, err)
        assert.Equal(t, int64(2000), tx.Amount)
        assert.Equal(t, models.TxStatusCompleted, tx.Status)
    })

    t.Run("Insufficient Balance", func(t *testing.T) {
        err := Transfer(user1.ID, user2.ID, 100000, "Too much")
        assert.Error(t, err)
        assert.Contains(t, err.Error(), "insufficient balance")
    })

    t.Run("Transfer to Self", func(t *testing.T) {
        err := Transfer(user1.ID, user1.ID, 100, "Self")
        assert.Error(t, err)
        assert.Equal(t, "cannot transfer to self", err.Error())
    })

    t.Run("Negative Amount", func(t *testing.T) {
        err := Transfer(user1.ID, user2.ID, -100, "Negative")
        assert.Error(t, err)
        assert.Equal(t, "amount must be positive", err.Error())
    })
}
