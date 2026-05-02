# 🍯 MELARIUM — Agro Investment Platform

A full-stack MVP for investing in beekeeping colonies, tracking honey production, and earning returns.

---

## 🏗️ Project Structure

```
MELARIUM/
├── bekent/    → Spring Boot 3.2 backend (Java 17, PostgreSQL)
├── front/     → React 18 + Vite web app
└── mobile/    → Flutter mobile app
```

---

## 🚀 Quick Start

### Prerequisites
- Java 17+, Maven 3.9+
- PostgreSQL 15+
- Node.js 18+
- Flutter 3.19+

---

### 1. Database Setup

```sql
CREATE DATABASE melarium_db;
CREATE USER melarium_user WITH PASSWORD 'melarium_pass';
GRANT ALL PRIVILEGES ON DATABASE melarium_db TO melarium_user;
```

---

### 2. Backend (Spring Boot)

```bash
cd bekent
mvn clean spring-boot:run
```

Server starts at `http://localhost:8080`

---

### 3. Frontend (React)

```bash
cd front
npm install
npm run dev
```

App opens at `http://localhost:5173`

---

### 4. Mobile (Flutter)

```bash
cd mobile
flutter pub get
flutter run
```

---

## 🔑 API Endpoints

### Auth
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/send-otp` | Send OTP to phone |
| POST | `/api/auth/verify-otp` | Verify OTP, get JWT |
| POST | `/api/auth/refresh` | Refresh access token |

### Marketplace (Public)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/colonies?status=&location=` | Browse colonies |
| GET | `/api/colonies/{id}` | Colony detail |

### Investments (INVESTOR)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/investments` | Buy shares |
| GET | `/api/investments/my` | My portfolio |
| PATCH | `/api/investments/{id}/honey-choice` | Set DELIVERY or SELL |

### Beekeeper (BEEKEEPER)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/colonies` | Create colony |
| PATCH | `/api/colonies/{id}/status` | Update status |
| PATCH | `/api/colonies/{id}/iot` | Update IoT data |
| POST | `/api/reports` | Submit honey report |
| POST | `/api/reports/{id}/finalize` | Finalize & distribute ROI |

### Admin (ADMIN)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/admin/stats` | Platform stats |
| GET | `/api/admin/users` | All users |
| PATCH | `/api/admin/users/{id}/role` | Change role |
| POST | `/api/admin/colonies/{id}/verify` | Approve colony |

### Payment (Mock)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/payment/click/prepare` | Click prepare webhook |
| POST | `/api/payment/click/confirm` | Click confirm webhook |
| POST | `/api/payment/payme/webhook` | Payme webhook |

---

## 👤 Roles

| Role | Capabilities |
|------|-------------|
| **INVESTOR** | Browse marketplace, buy shares, view portfolio, set honey choice |
| **BEEKEEPER** | Create/manage colonies, submit honey reports, update IoT data |
| **ADMIN** | Verify colonies, manage users, view all transactions & stats |

---

## 💡 Business Logic

- **Commission**: 8% on investments, 12% on honey sales
- **ROI Distribution**: Finalized honey reports trigger proportional payout to all active investors in a colony
- **OTP**: Simulated (code returned in API response) — replace with real SMS in production
- **Payments**: Click/Payme webhook simulation — replace with real integration in production

---

## 🗃️ Database Schema

| Table | Purpose |
|-------|---------|
| `users` | Phone-based auth, roles, OTP |
| `colonies` | Beekeeper-owned colonies with shares & IoT data |
| `investments` | Investor → Colony share purchases |
| `transactions` | Payment ledger |
| `honey_reports` | Beekeeper production reports |
| `notifications` | In-app notifications |
| `audit_logs` | Security audit trail |
