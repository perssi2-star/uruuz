package smileid

import (
"bytes"
"crypto/hmac"
"crypto/sha256"
"encoding/base64"
"encoding/json"
"fmt"
"io"
"net/http"
"time"
)

type Client struct {
BaseURL   string
PartnerID string
APIKey    string
HTTPClient *http.Client
}

func NewClient(baseURL, partnerID, apiKey string) *Client {
return &Client{
BaseURL:   baseURL,
PartnerID: partnerID,
APIKey:    apiKey,
HTTPClient: &http.Client{
Timeout: 30 * time.Second,
},
}
}

func (c *Client) GenerateSignature() (string, string, error) {
timestamp := time.Now().Format("2006-01-02T15:04:05.000Z")
message := timestamp + c.PartnerID + "sid_request"
h := hmac.New(sha256.New, []byte(c.APIKey))
h.Write([]byte(message))
signature := base64.StdEncoding.EncodeToString(h.Sum(nil))
return signature, timestamp, nil
}

type ImageInfo struct {
ImageTypeID int    `json:"image_type_id"`
Image       string `json:"image"` // Base64
}

type EnhancedKYCRequest struct {
PartnerID string `json:"partner_id"`
Timestamp string `json:"timestamp"`
Signature string `json:"signature"`
UserID    string `json:"user_id"`
JobID     string `json:"job_id"`
JobType   int    `json:"job_type"`
IDNumber  string `json:"id_number"`
IDType    string `json:"id_type"`
Country   string `json:"country"`
}

type EnhancedKYCResponse struct {
ResultCode    string `json:"ResultCode"`
ResultText    string `json:"ResultText"`
SmileJobID    string `json:"SmileJobID"`
PartnerParams struct {
JobType int    `json:"job_type"`
JobID   string `json:"job_id"`
UserID  string `json:"user_id"`
} `json:"PartnerParams"`
FullData struct {
FirstName   string `json:"FirstName"`
LastName    string `json:"LastName"`
MiddleName  string `json:"MiddleName"`
FullName    string `json:"FullName"`
DOB         string `json:"DOB"`
Gender      string `json:"Gender"`
IDNumber    string `json:"IDNumber"`
PhoneNumber string `json:"PhoneNumber"`
} `json:"FullData"`
}

type BiometricKYCRequest struct {
PartnerID string      `json:"partner_id"`
Timestamp string      `json:"timestamp"`
Signature string      `json:"signature"`
UserID    string      `json:"user_id"`
JobID     string      `json:"job_id"`
JobType   int         `json:"job_type"`
IDNumber  string      `json:"id_number"`
IDType    string      `json:"id_type"`
Country   string      `json:"country"`
Images    []ImageInfo `json:"images"`
}

type BiometricKYCResponse struct {
ResultCode string `json:"ResultCode"`
ResultText string `json:"ResultText"`
SmileJobID string `json:"SmileJobID"`
}

func (c *Client) EnhancedKYC(userID, jobID, idNumber, idType, country string) (*EnhancedKYCResponse, error) {
signature, timestamp, err := c.GenerateSignature()
if err != nil {
return nil, err
}

reqBody := EnhancedKYCRequest{
PartnerID: c.PartnerID,
Timestamp: timestamp,
Signature: signature,
UserID:    userID,
JobID:     jobID,
JobType:   4,
IDNumber:  idNumber,
IDType:    idType,
Country:   country,
}

jsonBody, err := json.Marshal(reqBody)
if err != nil {
return nil, err
}

resp, err := c.HTTPClient.Post(c.BaseURL+"/id_verification", "application/json", bytes.NewBuffer(jsonBody))
if err != nil {
return nil, err
}
defer resp.Body.Close()

bodyBytes, _ := io.ReadAll(resp.Body)
if resp.StatusCode != http.StatusOK {
return nil, fmt.Errorf("smile id error: status %d, body %s", resp.StatusCode, string(bodyBytes))
}

var kycResp EnhancedKYCResponse
if err := json.Unmarshal(bodyBytes, &kycResp); err != nil {
return nil, err
}

return &kycResp, nil
}

func (c *Client) BiometricKYC(userID, jobID, idNumber, idType, country, selfieBase64 string) (*BiometricKYCResponse, error) {
signature, timestamp, err := c.GenerateSignature()
if err != nil {
return nil, err
}

reqBody := BiometricKYCRequest{
PartnerID: c.PartnerID,
Timestamp: timestamp,
Signature: signature,
UserID:    userID,
JobID:     jobID,
JobType:   1,
IDNumber:  idNumber,
IDType:    idType,
Country:   country,
Images: []ImageInfo{
{
ImageTypeID: 0, // Selfie
Image:       selfieBase64,
},
},
}

jsonBody, err := json.Marshal(reqBody)
if err != nil {
return nil, err
}

resp, err := c.HTTPClient.Post(c.BaseURL+"/id_verification", "application/json", bytes.NewBuffer(jsonBody))
if err != nil {
return nil, err
}
defer resp.Body.Close()

bodyBytes, _ := io.ReadAll(resp.Body)
if resp.StatusCode != http.StatusOK {
return nil, fmt.Errorf("smile id error: status %d, body %s", resp.StatusCode, string(bodyBytes))
}

var kycResp BiometricKYCResponse
if err := json.Unmarshal(bodyBytes, &kycResp); err != nil {
return nil, err
}

return &kycResp, nil
}
