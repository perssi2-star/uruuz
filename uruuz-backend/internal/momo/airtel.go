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

// AirtelMoneyClient handles Airtel Money Uganda API
type AirtelMoneyClient struct {
	BaseURL    string
	ClientID   string
	Secret     string
	HTTPClient *http.Client
}

type AirtelTokenResponse struct {
	AccessToken string `json:"access_token"`
	ExpiresIn   string `json:"expires_in"`
	TokenType   string `json:"token_type"`
}

type AirtelCollectionRequest struct {
	Reference    string            `json:"reference"`
	Subscriber   AirtelSubscriber  `json:"subscriber"`
	Transaction  AirtelTransaction `json:"transaction"`
}

type AirtelSubscriber struct {
	Country  string `json:"country"`
	Currency string `json:"currency"`
	MSISDN   string `json:"msisdn"` // e.g. "256751234567"
}

type AirtelTransaction struct {
	Amount   float64 `json:"amount"`
	Country  string  `json:"country"`
	Currency string  `json:"currency"`
	ID       string  `json:"id"`
}

type AirtelCollectionResponse struct {
	Data   AirtelCollectionData `json:"data"`
	Status AirtelStatus         `json:"status"`
}

type AirtelCollectionData struct {
	Transaction AirtelTransactionResult `json:"transaction"`
}

type AirtelTransactionResult struct {
	ID     string `json:"id"`
	Status string `json:"status"` // TS (Success), TF (Failed), TP (Pending)
}

type AirtelStatus struct {
	Code    string `json:"code"`
	Message string `json:"message"`
	Success bool   `json:"success"`
}

type AirtelDisbursementRequest struct {
	Payee       AirtelPayee       `json:"payee"`
	Reference   string            `json:"reference"`
	Transaction AirtelTransaction `json:"transaction"`
}

type AirtelPayee struct {
	MSISDN string `json:"msisdn"`
}

// NewAirtelClient creates a new Airtel Money API client
func NewAirtelClient() *AirtelMoneyClient {
	env := os.Getenv("AIRTEL_ENVIRONMENT")
	baseURL := "https://openapi.airtel.africa"
	if env == "sandbox" {
		baseURL = "https://openapiuat.airtel.africa"
	}
	return &AirtelMoneyClient{
		BaseURL:    baseURL,
		ClientID:   os.Getenv("AIRTEL_CLIENT_ID"),
		Secret:     os.Getenv("AIRTEL_CLIENT_SECRET"),
		HTTPClient: &http.Client{Timeout: 30 * time.Second},
	}
}

// GetAccessToken retrieves an Airtel OAuth2 token
func (c *AirtelMoneyClient) GetAccessToken() (string, error) {
	url := fmt.Sprintf("%s/auth/oauth2/token", c.BaseURL)

	payload := map[string]string{
		"client_id":     c.ClientID,
		"client_secret": c.Secret,
		"grant_type":    "client_credentials",
	}
	body, _ := json.Marshal(payload)

	req, err := http.NewRequest("POST", url, bytes.NewBuffer(body))
	if err != nil {
		return "", err
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "*/*")

	resp, err := c.HTTPClient.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	var tokenResp AirtelTokenResponse
	if err := json.NewDecoder(resp.Body).Decode(&tokenResp); err != nil {
		return "", err
	}
	return tokenResp.AccessToken, nil
}

// CollectPayment initiates a payment collection from an Airtel subscriber
// msisdn: Uganda phone e.g. "256751234567"
// amount: in UGX
func (c *AirtelMoneyClient) CollectPayment(token, msisdn string, amount float64, description string) (string, error) {
	txnID := uuid.New().String()
	url := fmt.Sprintf("%s/merchant/v1/payments/", c.BaseURL)

	payload := AirtelCollectionRequest{
		Reference: description,
		Subscriber: AirtelSubscriber{
			Country:  "UG",
			Currency: "UGX",
			MSISDN:   msisdn,
		},
		Transaction: AirtelTransaction{
			Amount:   amount,
			Country:  "UG",
			Currency: "UGX",
			ID:       txnID,
		},
	}

	body, _ := json.Marshal(payload)
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(body))
	if err != nil {
		return "", err
	}

	req.Header.Set("Authorization", "Bearer "+token)
	req.Header.Set("X-Country", "UG")
	req.Header.Set("X-Currency", "UGX")
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")

	resp, err := c.HTTPClient.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		bodyBytes, _ := io.ReadAll(resp.Body)
		return "", fmt.Errorf("Airtel CollectPayment failed: %s - %s", resp.Status, string(bodyBytes))
	}

	var result AirtelCollectionResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return "", err
	}

	if !result.Status.Success {
		return "", fmt.Errorf("Airtel error: %s - %s", result.Status.Code, result.Status.Message)
	}

	return result.Data.Transaction.ID, nil
}

// GetTransactionStatus checks the status of an Airtel transaction
func (c *AirtelMoneyClient) GetTransactionStatus(token, transactionID string) (string, error) {
	url := fmt.Sprintf("%s/standard/v1/payments/%s", c.BaseURL, transactionID)
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return "", err
	}

	req.Header.Set("Authorization", "Bearer "+token)
	req.Header.Set("X-Country", "UG")
	req.Header.Set("X-Currency", "UGX")
	req.Header.Set("Accept", "application/json")

	resp, err := c.HTTPClient.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	var result AirtelCollectionResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return "", err
	}

	return result.Data.Transaction.Status, nil
}

// Disburse sends money to an Airtel subscriber (withdraw/cashout)
func (c *AirtelMoneyClient) Disburse(token, msisdn string, amount float64, reference string) (string, error) {
	txnID := uuid.New().String()
	url := fmt.Sprintf("%s/standard/v1/disbursements/", c.BaseURL)

	payload := AirtelDisbursementRequest{
		Payee:     AirtelPayee{MSISDN: msisdn},
		Reference: reference,
		Transaction: AirtelTransaction{
			Amount:   amount,
			Country:  "UG",
			Currency: "UGX",
			ID:       txnID,
		},
	}

	body, _ := json.Marshal(payload)
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(body))
	if err != nil {
		return "", err
	}

	req.Header.Set("Authorization", "Bearer "+token)
	req.Header.Set("X-Country", "UG")
	req.Header.Set("X-Currency", "UGX")
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")

	resp, err := c.HTTPClient.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		bodyBytes, _ := io.ReadAll(resp.Body)
		return "", fmt.Errorf("Airtel Disburse failed: %s - %s", resp.Status, string(bodyBytes))
	}

	var result AirtelCollectionResponse
	json.NewDecoder(resp.Body).Decode(&result)
	return result.Data.Transaction.ID, nil
}
