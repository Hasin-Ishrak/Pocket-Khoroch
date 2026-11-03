<div align="center">

# 💸 Pocket Khoroch

### The smart expense tracker built for students in Bangladesh

Track every taka, hit your savings goals, and get money advice in **Banglish**, from an AI that talks like a friendly senior.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Gemini](https://img.shields.io/badge/Gemini_AI-8E75B2?style=for-the-badge&logo=googlegemini&logoColor=white)
![PHP](https://img.shields.io/badge/PHP-777BB4?style=for-the-badge&logo=php&logoColor=white)

</div>

---

## 🎯 The Problem

Students living away from home juggle a tight monthly budget (mess bill, rent, transport, data, tuition) and most expense apps are built for salaried adults, are English-only, and need constant internet. **Pocket Khoroch** is designed around how students actually live and spend.


<!-- Add screenshots in a /screenshots folder, then uncomment -->
<!--
<p align="center">
  <img src="screenshots/home.png" width="22%" />
  <img src="screenshots/analytics.png" width="22%" />
  <img src="screenshots/chat.png" width="22%" />
  <img src="screenshots/savings.png" width="22%" />
</p>
-->

## ✨ Features

### 💰 Smart Tracking
- Add income and expenses with student-focused categories (food, transport, rent and more)
- **Math-expression input**: type `150+200+50` and it calculates the total for you
- Edit and delete transactions, with live balance, income and expense totals

### 📴 Offline-First
- Everything saves instantly to a local **Hive** database, so it works with no internet
- Background sync to **Cloud Firestore**, with unsynced entries retried automatically
- Cloud pull-and-merge to restore data on a new device

### 📊 Analytics
- Weekly, monthly and yearly views
- Category-wise **pie chart** and spending **trend bars** (fl_chart)

### 🎯 Savings Tools
- **Goal Calculator**: enter a target and deadline to get daily, weekly and monthly saving amounts
- **Rate Projector**: see how a daily, weekly or monthly saving habit grows over a year
- Saved goals synced to the cloud

### 🤖 Khoroch AI (Gemini)
- Chat assistant with a custom persona: warm, practical, never judgmental
- Understands **Banglish, mixed Bangla-English, slang and typos**, and replies in the user's own style
- Student-specific advice: mess bills, semester fees, allowance budgeting, saving targets
- Streaming responses

### ⏰ Reminders
- Scheduled local notifications for recurring bills and payments (timezone-aware)

### 👑 Freemium Model
- Reusable **ProGate** widget locks premium features (such as AI chat and reminders)
- Subscription flow: OTP verification, status, manage and unsubscribe screens
- PHP backend for the **BDApps** carrier-billing API

### 🔐 Accounts
- Email and Google Sign-In, forgot-password flow, editable profile

## 🏗️ Architecture

```
Pocket-Khoroch/
├── client_app/            # Flutter app
│   └── lib/
│       ├── models/        # Transaction, SavingsGoal, Reminder, Category...
│       ├── services/      # Local storage, cloud sync, AI, notifications
│       ├── repository/    # Offline-first data layer (local ⇄ cloud)
│       ├── providers/     # State management (Provider)
│       ├── pages/         # Auth, home, analytics, savings, chat, subscription
│       ├── widgets/       # Charts, ProGate, balance card...
│       └── utils/         # Router, analytics helper, expression evaluator
└── backend/               # PHP billing API (BDApps)
```

```
UI ──► Provider ──► Repository ──► Hive (local, instant)
                         └──────► Firestore (background sync)
```

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| App | Flutter, Dart, Provider, GoRouter |
| Local DB | Hive |
| Cloud | Firebase Auth, Cloud Firestore |
| AI | Google Gemini (`google_generative_ai`) |
| Charts | fl_chart |
| Notifications | flutter_local_notifications, timezone |
| Billing Backend | PHP + BDApps Subscription API |

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.x
- A Firebase project
- A [Gemini API key](https://aistudio.google.com/app/apikey)

### Run the app
```bash
git clone https://github.com/Hasin-Ishrak/Pocket-Khoroch.git
cd Pocket-Khoroch/client_app
flutter pub get
flutterfire configure
```

Create your secrets file from the example:
```bash
cp tool/secrets.secrets.json.example tool/secrets.json
```
```json
{
  "GEMINI_API_KEY": "your-gemini-api-key"
}
```

Run with the key injected at build time (never hard-coded):
```bash
flutter run --dart-define-from-file=tool/secrets.json
```

### Billing backend (optional)
```bash
cd backend
# Set BDAPPS_APP_ID and BDAPPS_PASSWORD via environment variables
php -S localhost:8000
```

## 🗺️ Roadmap
- [x] Offline-first transactions with cloud sync
- [x] Analytics, savings calculators, reminders
- [x] Gemini-powered Banglish finance assistant
- [ ] Switch the client from the mock subscription service to live BDApps billing
- [ ] Budget limits with overspending alerts
- [ ] Export reports (PDF/CSV)
- [ ] Bangla language UI

## 👨‍💻 Author

**Hasin Ishrak**, Software Engineering student at SUST, Bangladesh

[Portfolio](https://hasin-ishrak.github.io) · [GitHub](https://github.com/Hasin-Ishrak) · [Email](mailto:ishrakhasin758@gmail.com)

---

<div align="center">⭐ If this helped you, give it a star!</div>
