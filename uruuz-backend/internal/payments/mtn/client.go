package mtn

import (
"bytes"
"encoding/base64"
"encoding/json"
"fmt"
"io"
"net/http"
"time"

"github.com/google/uuid"
)

type Client struct {
BaseURL           string
SubscriptionKey   string
APIUser           string
APIKey            string
Environment       string
HTTPClient        *http.Client
}

func NewClient(baseURL, subKey, apiUser, apiKey, env string) *Client {
return &Client{
BaseURL:         baseURL,
SubscriptionKey: subKey,
APIUser:         apiUser,
APIKey:          apiKey,
Environment:     env,
HTTPClient: &http.Client{
Timeout: 30 * time.Second,
},
}
}

type TokenResponse struct {
AccessToken string `json:"access_token"`
TokenType   string `json:"token_type"`
ExpiresIn   int    `json:"expires_in"`
}

func (c *Client) GetToken(product string) (string, error) {
url := fmt.Sprintf("%s/%s/token/", c.BaseURL, product)
req, err := http.NewRequest("POST", url, nil)
if err != nil {
return "", err
}

auth := base64.StdEncoding.EncodeToString([]byte(fmt.Sprintf("%s:%s", c.APIUser, c.APIKey)))
req.Header.Set("Authorization", "Basic "+auth)
req.Header.Set("Ocp-Apim-Subscription-Key", c.SubscriptionKey)

resp, err := c.HTTPClient.Do(req)
if err != nil {
return "", err
}
defer resp.Body.Close()

if resp.StatusCode != http.StatusOK {
body, _ := io.ReadAll(resp.Body)
return "", fmt.Errorf("mtn token error: status %d, body %s", resp.StatusCode, string(body))
}

var tokenResp TokenResponse
if err := json.NewDecoder(resp.Body).Decode(&tokenResp); err != nil {
return "", err
}

return tokenResp.AccessToken, nil
}

type RequestToPayPayload struct {
Amount       string `json:"amount"`
Currency     string `json:"currency"`
ExternalID   string `json:"externalId"`
Payer        Payer  `json:"payer"`
PayerMessage string `json:"payerMessage"`
PayeeNote    string `json:"payeeNote"`
}

type Payer struct {
PartyIDType string `json:"partyIdType"` // MSISDN
PartyID     string `json:"partyId"`     // phone number
}

type TransactionStatus struct {
FinancialTransactionID string `json:"financialTransactionId"`
ExternalID             string `json:"externalId"`
Amount                 string `json:"amount"`
Currency               string `json:"currency"`
Payer                  Payer  `json:"payer"`
Status                 string `json:"status"` // PENDING, SUCCESSFUL, FAILED
Reason                 string `json:"reason"`
}

func (c *Client) RequestToPay(amount, currency, externalID, phone, message, note string) (string, error) {
token, err := c.GetToken("collection")
if err != nil {
return "", err
}

referenceID := uuid.New().String()
url := fmt.Sprintf("%s/collection/v1_0/requesttopay", c.BaseURL)

payload := RequestToPayPayload{
Amount:       amount,
Currency:     currency,
ExternalID:   externalID,
Payer: Payer{
PartyIDType: "MSISDN",
PartyID:     phone,
},
PayerMessage: message,
PayeeNote:    note,
}

jsonPayload, _ := json.Marshal(payload)
req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonPayload))
if err != nil {
return "", err
}

req.Header.Set("Authorization", "Bearer "+token)
req.Header.Set("X-Reference-Id", referenceID)
req.Header.Set("X-Target-Environment", c.Environment)
req.Header.Set("Content-Type", "application/json")
req.Header.Set("Ocp-Apim-Subscription-Key", c.SubscriptionKey)

resp, err := c.HTTPClient.Do(req)
if err != nil {
return "", err
}
defer resp.Body.Close()

if resp.StatusCode != http.StatusAccepted {
body, _ := io.ReadAll(resp.Body)
return "", fmt.Errorf("mtn requesttopay error: status %d, body %s", resp.StatusCode, string(body))
}

return referenceID, nil
}

func (c *Client) GetRequestToPayStatus(referenceID string) (*TransactionStatus, error) {
token, err := c.GetToken("collection")
if err != nil {
return nil, err
}

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

if resp.StatusCode != http.StatusOK {
body, _ := io.ReadAll(resp.Body)
return nil, fmt.Errorf("mtn getstatus error: status %d, body %s", resp.StatusCode, string(body))
}

var status TransactionStatus
if err := json.NewDecoder(resp.Body).Decode(&status); err != nil {
return nil, err
}

return &status, nil
}

// Disbursement
type TransferPayload struct {
Amount       string `json:"amount"`
Currency     string `json:"currency"`
ExternalID   string `json:"externalId"`
Payee        Payer  `json:"payee"`
PayerMessage string `json:"payerMessage"`
PayeeNote    string `json:"payeeNote"`
}

func (c *Client) Transfer(amount, currency, externalID, phone, message, note string) (string, error) {
token, err := c.GetToken("disbursement")
if err != nil {
return "", err
}

referenceID := uuid.New().String()
url := fmt.Sprintf("%s/disbursement/v1_0/transfer", c.BaseURL)

payload := TransferPayload{
Amount:       amount,
Currency:     currency,
ExternalID:   externalID,
Payee: Payer{
PartyIDType: "MSISDN",
PartyID:     phone,
},
PayerMessage: message,
PayeeNote:    note,
}

jsonPayload, _ := json.Marshal(payload)
req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonPayload))
if err != nil {
return "", err
}

req.Header.Set("Authorization", "Bearer "+token)
req.Header.Set("X-Reference-Id", referenceID)
req.Header.Set("X-Target-Environment", c.Environment)
req.Header.Set("Content-Type", "application/json")
req.Header.Set("Ocp-Apim-Subscription-Key", c.SubscriptionKey)

resp, err := c.HTTPClient.Do(req)
if err != nil {
return "", err
}
defer resp.Body.Close()

if resp.StatusCode != http.StatusAccepted {
body, _ := io.ReadAll(resp.Body)
return "", fmt.Errorf("mtn transfer error: status %d, body %s", resp.StatusCode, string(body))
}

return referenceID, nil
}

func (c *Client) GetTransferStatus(referenceID string) (*TransactionStatus, error) {
token, err := c.GetToken("disbursement")
if err != nil {
return nil, err
}

url := fmt.Sprintf("%s/disbursement/v1_0/transfer/%s", c.BaseURL, referenceID)
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

if resp.StatusCode != http.StatusOK {
body, _ := io.ReadAll(resp.Body)
return nil, fmt.Errorf("mtn gettransferstatus error: status %d, body %s", resp.StatusCode, string(body))
}

var status TransactionStatus
if err := json.NewDecoder(resp.Body).Decode(&status); err != nil {
return nil, err
}

return &status, nil
}
