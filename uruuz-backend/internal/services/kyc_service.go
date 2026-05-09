package services

import (
"errors"
"os"
"time"

"github.com/google/uuid"
"github.com/uruuz/uruuz-backend/internal/db"
"github.com/uruuz/uruuz-backend/internal/kyc/smileid"
"github.com/uruuz/uruuz-backend/internal/models"
)

type KYCService struct {
smileIDClient *smileid.Client
}

func NewKYCService() *KYCService {
partnerID := os.Getenv("SMILEID_PARTNER_ID")
apiKey := os.Getenv("SMILEID_API_KEY")
baseURL := os.Getenv("SMILEID_BASE_URL") // e.g. https://sandbox.smileidentity.com/v1
return &KYCService{
smileIDClient: smileid.NewClient(baseURL, partnerID, apiKey),
}
}

func (s *KYCService) VerifyNIN(userID uuid.UUID, nin string) (*models.KYC, error) {
// Check if already verified
var existingKYC models.KYC
if err := db.DB.Where("user_id = ?", userID).First(&existingKYC).Error; err == nil {
if existingKYC.Status == models.KYCStatusVerified {
return &existingKYC, nil
}
}

jobID := uuid.New().String()
resp, err := s.smileIDClient.EnhancedKYC(userID.String(), jobID, nin, "NATIONAL_ID", "UG")
if err != nil {
return nil, err
}

// ResultCode 1012 usually means success for Enhanced KYC
status := models.KYCStatusFailed
if resp.ResultCode == "1012" {
status = models.KYCStatusVerified
}

kyc := models.KYC{
UserID:           userID,
NIN:              nin,
Status:           status,
FullName:         resp.FullData.FullName,
DOB:              resp.FullData.DOB,
Gender:           resp.FullData.Gender,
SmileJobID:       resp.SmileJobID,
VerificationDate: time.Now(),
}

if err := db.DB.Save(&kyc).Error; err != nil {
return nil, err
}

return &kyc, nil
}

func (s *KYCService) VerifyFace(userID uuid.UUID, selfieBase64 string) (*models.KYC, error) {
var kyc models.KYC
if err := db.DB.Where("user_id = ?", userID).First(&kyc).Error; err != nil {
return nil, errors.New("KYC record not found. Please verify NIN first")
}

jobID := uuid.New().String()
resp, err := s.smileIDClient.BiometricKYC(userID.String(), jobID, kyc.NIN, "NATIONAL_ID", "UG", selfieBase64)
if err != nil {
return nil, err
}

if resp.ResultCode == "1012" {
kyc.IsBiometricMatched = true
}

if err := db.DB.Save(&kyc).Error; err != nil {
return nil, err
}

return &kyc, nil
}

func (s *KYCService) GetKYCStatus(userID uuid.UUID) (*models.KYC, error) {
var kyc models.KYC
if err := db.DB.Where("user_id = ?", userID).First(&kyc).Error; err != nil {
return nil, err
}
return &kyc, nil
}
