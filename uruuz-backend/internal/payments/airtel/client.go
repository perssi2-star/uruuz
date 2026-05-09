package airtel

import (
"bytes"
"encoding/json"
"fmt"
"io"
"net/http"
"time"
)

type Client struct {
BaseURL      string
ClientID     string
ClientSecret string
HTTPClient   *http.Client
}

func NewClient(baseURL, clientID, clientSecret string) *Client {
return &Client{
BaseURL:      baseURL,
ClientID:     clientID,
ClientSecret: clientSecret,
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

func (c *Client) GetToken() (string, error) {
url := fmt.Sprintf("%s/auth/oauth2/token", c.BaseURL)
payload := map[string]string{
"client_id":     c.ClientID,
"client_secret": c.ClientSecret,
"grant_type":    "client_credentials",
}

jsonPayload, _ := json.Marshal(payload)
req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonPayload))
if err != nil {
return "", err
}
req.Header.Set("Content-Type", "application/json")

resp, err := c.HTTPClient.Do(req)
if err != nil {
return "", err
}
defer resp.Body.Close()

if resp.StatusCode != http.StatusOK {
body, _ := io.ReadAll(resp.Body)
return "", fmt.Errorf("airtel token error: status %d, body %s", resp.StatusCode, string(body))
}

var tokenResp TokenResponse
if err := json.NewDecoder(resp.Body).Decode(&tokenResp); err != nil {
return "", err
}

return tokenResp.AccessToken, nil
}

type CollectionPayload struct {
Reference string `json:"reference"`
Subscriber struct {
Msisdn string `json:"msisdn"`
} `json:"subscriber"`
Transaction struct {
Amount   float64 `json:"amount"`
ID       string  `json:"id"`
} `json:"transaction"`
}

func (c *Client) Collect(amount float64, phone, reference, transactionID string) (string, error) {
token, err := c.GetToken()
if err != nil {
return "", err
}

url := fmt.Sprintf("%s/merchant/v1/payments/", c.BaseURL)
payload := CollectionPayload{
Reference: reference,
}
payload.Subscriber.Msisdn = phone
payload.Transaction.Amount = amount
payload.Transaction.ID = transactionID

jsonPayload, _ := json.Marshal(payload)
req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonPayload))
if err != nil {
return "", err
}

req.Header.Set("Content-Type", "application/json")
req.Header.Set("Authorization", "Bearer "+token)
req.Header.Set("X-Country", "UG")
req.Header.Set("X-Currency", "UGX")

resp, err := c.HTTPClient.Do(req)
if err != nil {
return "", err
}
defer resp.Body.Close()

body, _ := io.ReadAll(resp.Body)
if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusAccepted {
return "", fmt.Errorf("airtel collection error: status %d, body %s", resp.StatusCode, string(body))
}

return string(body), nil
}

// Similarly for Disbursement
