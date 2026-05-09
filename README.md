# 🇺🇬 Uruuz — Uganda's Super Fintech App

**Uruuz** is a Uganda-focused fintech platform — similar to Wise + Revolut — built for the Ugandan market with Uganda Shilling (UGX) as the primary currency.

## 🏗️ Project Structure

```
uruuz/
├── uruuz-backend/       # Go backend API server
└── uruuz-mobile/        # Flutter mobile app (Android & iOS)
```

---

## 📱 Mobile App (Flutter)

**Location:** `uruuz-mobile/`

### Features Built
- ✅ **Authentication** — Signup, Login, 6-digit PIN, JWT session management
- ✅ **KYC Onboarding** — NIN verification, selfie biometric (Smile ID integration)
- ✅ **Wallet & Transfers** — UGX wallet balance, P2P send money
- ✅ **Merchant Payments** — EMVCo QR code generation (static & dynamic), merchant dashboard
- ✅ **Bill Payments** — Umeme electricity, NWSC water, DSTV, internet
- ✅ **Loans & Savings** — Micro-loan application, savings with 12% APY
- ✅ **Agent Banking** — USSD support for feature phones

### Tech Stack
- **Framework:** Flutter (Dart)
- **State Management:** Provider
- **Secure Storage:** flutter_secure_storage (JWT tokens)
- **HTTP:** Dio

### Run Locally
```bash
cd uruuz-mobile
flutter pub get
flutter run
```

---

## ⚙️ Backend API (Go)

**Location:** `uruuz-backend/`

### Features Built
- ✅ **Authentication API** — JWT tokens, PIN hashing (bcrypt), refresh tokens
- ✅ **Wallet Service** — UGX ledger, P2P transfers with DB-level locking (race condition safe)
- ✅ **KYC Service** — Smile ID NIN + face verification integration
- ✅ **Mobile Money Integration** — Unified MTN MoMo + Airtel Money API (collections & disbursements)
- ✅ **Health Check** — `/health` endpoint

### Tech Stack
- **Language:** Go (Golang)
- **Framework:** Gin
- **ORM:** GORM
- **Database:** PostgreSQL (transactions) + Redis (cache/sessions)
- **Containerization:** Docker + Docker Compose

### Environment Variables
Create a `.env` file in `uruuz-backend/`:
```env
DATABASE_URL=postgres://user:password@localhost:5432/uruuz
REDIS_URL=redis://localhost:6379
JWT_SECRET=your_jwt_secret_here

# MTN Mobile Money
MTN_COLLECTION_SUBSCRIPTION_KEY=your_key
MTN_DISBURSEMENT_SUBSCRIPTION_KEY=your_key
MTN_USER_ID=your_user_id
MTN_API_KEY=your_api_key
MTN_ENVIRONMENT=sandbox

# Airtel Money
AIRTEL_CLIENT_ID=your_client_id
AIRTEL_CLIENT_SECRET=your_secret
AIRTEL_ENVIRONMENT=sandbox

# Smile ID (KYC)
SMILEID_API_KEY=your_key
SMILEID_PARTNER_ID=your_partner_id
```

### Run Locally
```bash
cd uruuz-backend
docker-compose up -d     # Start PostgreSQL + Redis
go run cmd/api/main.go   # Start API server on :8080
```

### API Endpoints (Protected by AuthMiddleware)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |
| POST | `/auth/signup` | Register new user |
| POST | `/auth/login` | Login with phone + PIN |
| GET | `/wallets/:user_id/balance` | Get wallet balance |
| GET | `/wallets/:user_id/history` | Get transaction history |
| POST | `/wallets/:user_id/transfer` | P2P transfer (UGX) |
| POST | `/kyc/:user_id/verify-nin` | Verify National ID (NIN) |
| POST | `/kyc/:user_id/verify-face` | Biometric face match |
| GET | `/kyc/:user_id/status` | Get KYC verification status |
| POST | `/payments/momo/collect` | Collect UGX from Mobile Money |
| POST | `/payments/momo/disburse` | Disburse UGX to Mobile Money |
| GET | `/payments/momo/status/:ref` | Poll MoMo transaction status |

---

## 🏦 Regulatory & Compliance

- **Regulator:** Bank of Uganda (BoU)
- **License Type:** Electronic Money Issuer (EMI) under NPS Act 2020
- **Capital Requirement:** 250 Million UGX
- **KYC Tiers:** 3-tier system (NIN → Face → Business docs)
- **AML:** FIA compliance, STR within 48hrs, LCTR for transactions >20M UGX
- **Data Protection:** Uganda Data Protection Act 2019 (AES-256, TLS 1.3)

Full compliance roadmap: `research/compliance_roadmap.md`

---

## 🗺️ Roadmap

- [ ] Deploy backend to production (Railway/Render)
- [ ] Submit to BoU for EMI license
- [ ] MTN & Airtel live API credentials (sandbox → production)
- [ ] Smile ID production KYC go-live
- [ ] Google Play Store submission
- [ ] Agent banking USSD integration
- [ ] International remittances (Wise API corridor)

---

## 👥 Team

Built by the **Uruuz Engineering Team** for the Ugandan market.

> *"Banking the unbanked, one shilling at a time."*
