package models

import (
"time"

"github.com/google/uuid"
"gorm.io/gorm"
)

type User struct {
ID        uuid.UUID      `gorm:"type:uuid;primaryKey" json:"id"`
FirstName string         `gorm:"size:100;not null" json:"first_name"`
LastName  string         `gorm:"size:100;not null" json:"last_name"`
Email     string         `gorm:"size:100;unique;not null" json:"email"`
Phone     string         `gorm:"size:20;unique;not null" json:"phone"`
Pin       string         `gorm:"size:255;not null" json:"-"` // Hashed PIN
CreatedAt time.Time      `json:"created_at"`
UpdatedAt time.Time      `json:"updated_at"`
DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
Wallet    Wallet         `json:"wallet"`
}

func (u *User) BeforeCreate(tx *gorm.DB) (err error) {
u.ID = uuid.New()
return
}

type Wallet struct {
ID        uuid.UUID `gorm:"type:uuid;primaryKey" json:"id"`
UserID    uuid.UUID `gorm:"type:uuid;index;not null" json:"user_id"`
Currency  string    `gorm:"size:3;default:'UGX';not null" json:"currency"`
Balance   int64     `gorm:"default:0;not null" json:"balance"` // Amount in smallest unit (UGX 1)
CreatedAt time.Time `json:"created_at"`
UpdatedAt time.Time `json:"updated_at"`
}

func (w *Wallet) BeforeCreate(tx *gorm.DB) (err error) {
w.ID = uuid.New()
return
}

type TransactionType string

const (
TxTypeDeposit    TransactionType = "DEPOSIT"
TxTypeWithdrawal TransactionType = "WITHDRAWAL"
TxTypeTransfer   TransactionType = "TRANSFER"
)

type TransactionStatus string

const (
TxStatusPending   TransactionStatus = "PENDING"
TxStatusCompleted TransactionStatus = "COMPLETED"
TxStatusFailed    TransactionStatus = "FAILED"
)

type Transaction struct {
ID               uuid.UUID         `gorm:"type:uuid;primaryKey" json:"id"`
SenderWalletID   *uuid.UUID        `gorm:"type:uuid;index" json:"sender_wallet_id,omitempty"`
ReceiverWalletID *uuid.UUID        `gorm:"type:uuid;index" json:"receiver_wallet_id,omitempty"`
Amount           int64             `gorm:"not null" json:"amount"`
Currency         string            `gorm:"size:3;default:'UGX';not null" json:"currency"`
Type             TransactionType   `gorm:"type:varchar(20);not null" json:"type"`
Status           TransactionStatus `gorm:"type:varchar(20);default:'PENDING';not null" json:"status"`
Provider         string            `gorm:"size:20" json:"provider,omitempty"`
Reference        string            `gorm:"size:100;unique;not null" json:"reference"`
Description      string            `gorm:"size:255" json: "description"`
CreatedAt        time.Time         `json:"created_at"`
UpdatedAt        time.Time         `json:"updated_at"`
}

func (t *Transaction) BeforeCreate(tx *gorm.DB) (err error) {
t.ID = uuid.New()
return
}

type KYCStatus string

const (
KYCStatusPending  KYCStatus = "PENDING"
KYCStatusVerified KYCStatus = "VERIFIED"
KYCStatusFailed   KYCStatus = "FAILED"
)

type KYC struct {
ID                 uuid.UUID `gorm:"type:uuid;primaryKey" json:"id"`
UserID             uuid.UUID `gorm:"type:uuid;uniqueIndex;not null" json:"user_id"`
NIN                string    `gorm:"size:20;uniqueIndex" json:"nin"`
Status             KYCStatus `gorm:"type:varchar(20);default:'PENDING';not null" json:"status"`
FullName           string    `gorm:"size:255" json:"full_name"`
DOB                string    `gorm:"size:20" json:"dob"`
Gender             string    `gorm:"size:10" json:"gender"`
SmileJobID         string    `gorm:"size:100" json:"smile_job_id"`
IsBiometricMatched bool      `gorm:"default:false" json:"is_biometric_matched"`
VerificationDate   time.Time `json:"verification_date"`
CreatedAt          time.Time `json:"created_at"`
UpdatedAt          time.Time `json:"updated_at"`
}

func (k *KYC) BeforeCreate(tx *gorm.DB) (err error) {
k.ID = uuid.New()
return
}
