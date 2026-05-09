package momo

import (
    "fmt"
    "os"
)

// MoMoService is the unified service for MTN and Airtel Money in Uganda
type MoMoService struct {
    MTN    *MTNMoMoClient
    Airtel *AirtelMoneyClient
}

type DepositRequest struct {
    PhoneNumber string  // Uganda format: 256XXXXXXXXX
    Amount      float64 // Amount in UGX
    Reference   string  // Uruuz transaction reference
    Note        string
}

type WithdrawRequest struct {
    PhoneNumber string
    Amount      float64
    Reference   string
    Note        string
}

type MoMoResponse struct {
    Provider    string // "MTN" or "AIRTEL"
    ReferenceID string // Provider transaction reference
    Status      string // PENDING, SUCCESSFUL, FAILED
}

// NewMoMoService creates the unified Mobile Money service
func NewMoMoService() *MoMoService {
    return &MoMoService{
        MTN:    NewMTNClient(),
        Airtel: NewAirtelClient(),
    }
}

// DetectProvider determines the telco from a Uganda phone number
// MTN: 077x, 078x, 039x
// Airtel: 070x, 075x, 074x
func DetectProvider(phone string) (string, error) {
    if len(phone) < 12 {
        return "", fmt.Errorf("invalid Uganda phone number: %s", phone)
    }
    // Normalize: 256XXXXXXXXX
    prefix := phone[3:6] // e.g. "077", "075"
    switch prefix {
    case "077", "078", "039", "031":
        return "MTN", nil
    case "070", "075", "074", "041":
        return "AIRTEL", nil
    default:
        return "", fmt.Errorf("unknown provider for prefix %s", prefix)
    }
}

// Deposit collects money from a customer's mobile wallet into Uruuz
func (s *MoMoService) Deposit(req DepositRequest) (*MoMoResponse, error) {
    provider, err := DetectProvider(req.PhoneNumber)
    if err != nil {
        return nil, err
    }

    switch provider {
    case "MTN":
        token, err := s.MTN.GetAccessToken(
            os.Getenv("MTN_USER_ID"),
            os.Getenv("MTN_API_KEY"),
        )
        if err != nil {
            return nil, fmt.Errorf("MTN auth failed: %w", err)
        }
        refID, err := s.MTN.RequestToPay(
            token,
            req.PhoneNumber,
            fmt.Sprintf("%.0f", req.Amount),
            req.Reference,
            req.Note,
        )
        if err != nil {
            return nil, err
        }
        return &MoMoResponse{Provider: "MTN", ReferenceID: refID, Status: "PENDING"}, nil

    case "AIRTEL":
        token, err := s.Airtel.GetAccessToken()
        if err != nil {
            return nil, fmt.Errorf("Airtel auth failed: %w", err)
        }
        txnID, err := s.Airtel.CollectPayment(token, req.PhoneNumber, req.Amount, req.Note)
        if err != nil {
            return nil, err
        }
        return &MoMoResponse{Provider: "AIRTEL", ReferenceID: txnID, Status: "PENDING"}, nil
    }

    return nil, fmt.Errorf("unsupported provider: %s", provider)
}

// Withdraw sends money from Uruuz back to a customer's mobile wallet
func (s *MoMoService) Withdraw(req WithdrawRequest) (*MoMoResponse, error) {
    provider, err := DetectProvider(req.PhoneNumber)
    if err != nil {
        return nil, err
    }

    switch provider {
    case "MTN":
        token, err := s.MTN.GetAccessToken(
            os.Getenv("MTN_DISBURSEMENT_USER_ID"),
            os.Getenv("MTN_DISBURSEMENT_API_KEY"),
        )
        if err != nil {
            return nil, fmt.Errorf("MTN disbursement auth failed: %w", err)
        }
        refID, err := s.MTN.Disburse(
            token,
            req.PhoneNumber,
            fmt.Sprintf("%.0f", req.Amount),
            req.Reference,
            req.Note,
        )
        if err != nil {
            return nil, err
        }
        return &MoMoResponse{Provider: "MTN", ReferenceID: refID, Status: "PENDING"}, nil

    case "AIRTEL":
        token, err := s.Airtel.GetAccessToken()
        if err != nil {
            return nil, fmt.Errorf("Airtel auth failed: %w", err)
        }
        txnID, err := s.Airtel.Disburse(token, req.PhoneNumber, req.Amount, req.Note)
        if err != nil {
            return nil, err
        }
        return &MoMoResponse{Provider: "AIRTEL", ReferenceID: txnID, Status: "PENDING"}, nil
    }

    return nil, fmt.Errorf("unsupported provider: %s", provider)
}

// CheckStatus checks the status of any Mobile Money transaction
func (s *MoMoService) CheckStatus(provider, referenceID string) (string, error) {
    switch provider {
    case "MTN":
        token, err := s.MTN.GetAccessToken(
            os.Getenv("MTN_API_USER"),
            os.Getenv("MTN_API_KEY"),
        )
        if err != nil {
            return "", err
        }
        status, err := s.MTN.GetPaymentStatus(token, referenceID)
        if err != nil {
            return "", err
        }
        return status.Status, nil // SUCCESSFUL, FAILED, PENDING

    case "AIRTEL":
        token, err := s.Airtel.GetAccessToken()
        if err != nil {
            return "", err
        }
        status, err := s.Airtel.GetTransactionStatus(token, referenceID)
        if err != nil {
            return "", err
        }
        // Map Airtel status to common format
        switch status {
        case "TS":
            return "SUCCESSFUL", nil
        case "TF":
            return "FAILED", nil
        default:
            return "PENDING", nil
        }
    }

    return "", fmt.Errorf("unknown provider: %s", provider)
}
