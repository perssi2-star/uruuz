package services

import (
	"fmt"
	"os"

	"github.com/google/uuid"
	"github.com/uruuz/uruuz-backend/internal/db"
	"github.com/uruuz/uruuz-backend/internal/models"
	"github.com/uruuz/uruuz-backend/internal/momo"
	"gorm.io/gorm"
)

type PaymentService struct {
	momoService   *momo.MoMoService
	walletService *WalletService
}

func NewPaymentService() *PaymentService {
	return &PaymentService{
		momoService:   momo.NewMoMoService(),
		walletService: NewWalletService(),
	}
}

func (s *PaymentService) CollectFromMoMo(userID uuid.UUID, amount int64, phone string) (string, error) {
	wallet, err := s.walletService.GetWalletByUserID(userID)
	if err != nil {
		return "", err
	}

	provider, err := momo.DetectProvider(phone)
	if err != nil {
		return "", err
	}

	tx := models.Transaction{
		ReceiverWalletID: &wallet.ID,
		Amount:           amount,
		Currency:         "UGX",
		Type:             models.TxTypeDeposit,
		Status:           models.TxStatusPending,
		Provider:         provider,
		Reference:        uuid.New().String(),
		Description:      fmt.Sprintf("MoMo Collection from %s", phone),
	}

	if err := db.DB.Create(&tx).Error; err != nil {
		return "", err
	}

	res, err := s.momoService.Deposit(momo.DepositRequest{
		PhoneNumber: phone,
		Amount:      float64(amount),
		Reference:   tx.Reference,
		Note:        "Uruuz Deposit",
	})
	if err != nil {
		tx.Status = models.TxStatusFailed
		db.DB.Save(&tx)
		return "", err
	}

	return res.ReferenceID, nil
}

func (s *PaymentService) CheckMoMoStatus(referenceID string) (*models.Transaction, error) {
	var tx models.Transaction
	// Search by internal reference or provider reference
	if err := db.DB.Where("reference = ?", referenceID).First(&tx).Error; err != nil {
		return nil, err
	}

	if tx.Status != models.TxStatusPending {
		return &tx, nil
	}

	status, err := s.momoService.CheckStatus(tx.Provider, referenceID)
	if err != nil {
		return nil, err
	}

	if status == "SUCCESSFUL" {
		err := db.DB.Transaction(func(dbTx *gorm.DB) error {
			tx.Status = models.TxStatusCompleted
			if err := dbTx.Save(&tx).Error; err != nil {
				return err
			}

			var wallet models.Wallet
			if err := dbTx.Set("gorm:query_option", "FOR UPDATE").Where("id = ?", tx.ReceiverWalletID).First(&wallet).Error; err != nil {
				return err
			}

			wallet.Balance += tx.Amount
			if err := dbTx.Save(&wallet).Error; err != nil {
				return err
			}

			return nil
		})
		if err != nil {
			return nil, err
		}
	} else if status == "FAILED" {
		tx.Status = models.TxStatusFailed
		db.DB.Save(&tx)
	}

	return &tx, nil
}

func (s *PaymentService) DisburseToMoMo(userID uuid.UUID, amount int64, phone string) (string, error) {
	wallet, err := s.walletService.GetWalletByUserID(userID)
	if err != nil {
		return "", err
	}

	if wallet.Balance < amount {
		return "", fmt.Errorf("insufficient balance")
	}

	provider, err := momo.DetectProvider(phone)
	if err != nil {
		return "", err
	}

	tx := models.Transaction{
		SenderWalletID: &wallet.ID,
		Amount:         amount,
		Currency:       "UGX",
		Type:           models.TxTypeWithdrawal,
		Status:         models.TxStatusPending,
		Provider:       provider,
		Reference:      uuid.New().String(),
		Description:    fmt.Sprintf("MoMo Disbursement to %s", phone),
	}

	err = db.DB.Transaction(func(dbTx *gorm.DB) error {
		if err := dbTx.Create(&tx).Error; err != nil {
			return err
		}

		var w models.Wallet
		if err := dbTx.Set("gorm:query_option", "FOR UPDATE").Where("id = ?", wallet.ID).First(&w).Error; err != nil {
			return err
		}

		if w.Balance < amount {
			return fmt.Errorf("insufficient balance")
		}

		w.Balance -= amount
		return dbTx.Save(&w).Error
	})

	if err != nil {
		return "", err
	}

	res, err := s.momoService.Withdraw(momo.WithdrawRequest{
		PhoneNumber: phone,
		Amount:      float64(amount),
		Reference:   tx.Reference,
		Note:        "Uruuz Withdrawal",
	})
	if err != nil {
		db.DB.Transaction(func(dbTx *gorm.DB) error {
			tx.Status = models.TxStatusFailed
			dbTx.Save(&tx)

			var w models.Wallet
			dbTx.Where("id = ?", wallet.ID).First(&w)
			w.Balance += amount
			return dbTx.Save(&w).Error
		})
		return "", err
	}

	return res.ReferenceID, nil
}
