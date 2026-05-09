package momo

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"time"

	"github.com/google/uuid"
)

// MTNMoMoClient handles MTN Mobile Money API (Collections + Disbursements)
type MTNMoMoClient struct {
	BaseURL         string
	SubscriptionKey string
	APIKey          string
	Environment     string // "sandbox" or "production"
	HTTPClient      *http.Client
}

type MTNTokenResponse struct {
	AccessToken string `json:"access_token"`
	TokenType   string `json:"token_type"`
	ExpiresIn   int    `json:"expires_in"`
}

type MTNPaymentRequest struct {
	Amount       string `json:"amount"`
	Currency     string `json:"currency"`
	ExternalID   string `json:"externalId"`
	Payer        MTNParty `json:"payer"`
	PayerMessage string `json:"payerMessage"`
	PayeeNote    string `json:"payeeNote"`
}

type MTNParty struct {
	PartyIDType string `json:"partyIdType"`
	PartyID     string `json:"partyId"`
}

type MTNPaymentStatus struct {
	Amount                 string   `json:"amount"`
	Currency               string   `json:"currency"`
	FinancialTransactionID string   `json:"financialTransactionId"`
	ExternalID             string   `json:"externalId"`
	Payer                  MTNParty `json:"payer"`
	PayerMessage           string   `json:"payerMessage"`
	PayeeNote              string   `json:"payeeNote"`
	Status                 string   `json:"status"` // SUCCESSFUL, FAILED, PENDING
	Reason                 *MTNReason `json:"reason,omitempty"`
}

type MTNReason struct {
	Code    string `json:"code"`
	Message string `json:"message"`
}

// NewMTNClient creates a new MTN MoMo API client
func NewMTNClient() *MTNMoMoClient {
	env := os.Getenv("MTN_ENVIRONMENT")
	if env == "" {
		env = "sandbox"
	}
	baseURL := "https://sandbox.momodeveloper.mtn.com"
	if env == "production" {
		baseURL = "https://proxy.momoapi.mtn.com"
	}
	return &MTNMoMoClient{
		BaseURL:         baseURL,
		SubscriptionKey: os.Getenv("MTN_COLLECTION_SUBSCRIPTION_KEY"),
		APIKey:          os.Getenv("MTN_API_KEY"),
		Environment:     env,
		HTTPClient:      &http.Client{Timeout: 30 * time.Second},
	}
}

// GetAccessToken retrieves an OAuth token for the Collections API
func (c *MTNMoMoClient) GetAccessToken(userID, apiKey string) (string, error) {
	url := fmt.Sprintf("%s/collection/token/", c.BaseURL)
	req, err := http.NewRequest("POST", url, nil)
	if err != nil {
		return "", err
	}
	req.SetBasicAuth(userID, apiKey)
	req.Header.Set("Ocp-Apim-Subscription-Key", c.SubscriptionKey)

	resp, err := c.HTTPClient.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	var tokenResp MTNTokenResponse
	if err := json.NewDecoder(resp.Body).Decode(&tokenResp); err != nil {
		return "", err
	}
	return tokenResp.AccessToken, nil
}

// RequestToPay initiates a Mobile Money collection from a customer
// phoneNumber: Uganda format e.g. "256771234567"
// amountUGX: amount in Uganda Shillings
func (c *MTNMoMoClient) RequestToPay(token, phoneNumber, amountUGX, externalID, note string) (string, error) {
	referenceID := uuid.New().String()
	url := fmt.Sprintf("%s/collection/v1_0/requesttopay", c.BaseURL)

	payload := MTNPaymentRequest{
		Amount:       amountUGX,
		Currency:     "UGX",
		ExternalID:   externalID,
		Payer:        MTNParty{PartyIDType: "MSISDN", PartyID: phoneNumber},
		PayerMessage: note,
		PayeeNote:    "Uruuz Payment",
	}

	body, _ := json.Marshal(payload)
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(body))
	if err != nil {
		return "", err
	}

	req.Header.Set("Authorization", "Bearer "+token)
	req.Header.Set("X-Reference-Id", referenceID)
	req.Header.Set("X-Target-Environment", c.Environment)
	req.Header.Set("Ocp-Apim-Subscription-Key", c.SubscriptionKey)
	req.Header.Set("Content-Type", "application/json")

	resp, err := c.HTTPClient.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusAccepted {
		bodyBytes, _ := io.ReadAll(resp.Body)
		return "", fmt.Errorf("MTN RequestToPay failed: %s - %s", resp.Status, string(bodyBytes))
	}

	return referenceID, nil
}

// GetPaymentStatus checks the status of a RequestToPay transaction
func (c *MTNMoMoClient) GetPaymentStatus(token, referenceID string) (*MTNPaymentStatus, error) {
	url := fmt.Sprintf("%s/collection/v1_0/requesttopay/%s", c.BaseURL, referenceID)
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, err
	}

	req.Header.Set("Authorization", "Bearer "+token)
	req.Header.Set("X-Target-Environment", c.Environment)
	req.Header.Set("Ocp-Apim-Subscription-Key", c.SubscriptionKey)

	resp, err := c.HTTPClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	var status MTNPaymentStatus
	if err := json.NewDecoder(resp.Body).Decode(&status); err != nil {
		return nil, err
	}
	return &status, nil
}

// Disburse sends money from Uruuz to a customer's MTN number (Disbursements API)
func (c *MTNMoMoClient) Disburse(token, phoneNumber, amountUGX, externalID, note string) (string, error) {
	referenceID := uuid.New().String()
	url := fmt.Sprintf("%s/disbursement/v1_0/transfer", c.BaseURL)

	payload := map[string]interface{}{
		"amount":       amountUGX,
		"currency":     "UGX",
		"externalId":   externalID,
		"payee":        map[string]string{"partyIdType": "MSISDN", "partyId": phoneNumber},
		"payerMessage": "Uruuz Withdrawal",
		"payeeNote":    note,
	}

	body, _ := json.Marshal(payload)
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(body))
	if err != nil {
		return "", err
	}

	req.Header.Set("Authorization", "Bearer "+token)
	req.Header.Set("X-Reference-Id", referenceID)
	req.Header.Set("X-Target-Environment", c.Environment)
	req.Header.Set("Ocp-Apim-Subscription-Key", os.Getenv("MTN_DISBURSEMENT_SUBSCRIPTION_KEY"))
	req.Header.Set("Content-Type", "application/json")

	resp, err := c.HTTPClient.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusAccepted {
		bodyBytes, _ := io.ReadAll(resp.Body)
		return "", fmt.Errorf("MTN Disburse failed: %s - %s", resp.Status, string(bodyBytes))
	}

	return referenceID, nil
}
