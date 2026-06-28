# CLOSERRR — COMPLETE PROJECT CONTEXT DOCUMENT
### FOR AI: Read **`../workcontext.md`** fully at session start. Read this file only when workcontext.md says you need deeper product/architecture detail.

---

## 🧠 WHO IS THE USER?

- Name: (founder of Closerrr)
- Age: 25
- Background: Non-developer / no coding knowledge
- Company: **Closerrr Interactive** (new company) | previously **Shark Brews International** (old company)
- Situation: Self-funded, bootstrapped. Spent 2+ years building this app with a hired developer who delayed massively. Has a potential investor who will invest IF the user can show initial traction within **30-45 days** (investor's words). User has decided to use ~7-10 days to build and launch an MVP.
- Urgency: **EXTREMELY HIGH. This is a now-or-never situation.**
- The user needs to be guided like a complete beginner — explain everything step by step, no assumptions about technical knowledge.

---

## 📱 WHAT IS CLOSERRR?

Closerrr is a **creator-fan relationship platform** — think of it as an "Indianised version of Bubble (the US celebrity fan app)". It connects Indian influencers/celebrities ("Stars" or "Creators") with their fans.

### Core Features:
- **Fan & Creator roles** (two types of users)
- **Subscriptions** — Fans pay monthly to subscribe to a Creator for exclusive access
- **Direct Messaging / Chat** — Real-time 1:1 and group chat between fans and creators
- **Stories** — Creators post stories for fans
- **Live Streaming** — Creators go live, fans watch and comment
- **Events** — Creators create events, fans RSVP
- **Explore/Discovery** — Fans discover and browse creators
- **Payouts** — Creators receive earnings via Cashfree payout system
- **Push Notifications** — via Firebase FCM
- **In-App Purchases** — Google Play + Apple App Store subscriptions
- **OTP Verification** — Phone/email OTP for login
- **Google + Apple Sign-in** — Third party auth

### Package Name / Bundle ID:
- `com.sharkbrewsinternational.closerrr` (this is in the code — may need updating to Closerrr Interactive)

### Firebase Project:
- Project ID: `closerrr-56695`
- (Need to verify if this is accessible on Closerrr Interactive account or needs to be recreated)

---

## 📂 REPOSITORIES

Both repos are public on GitHub under the org `closerrrinteractive`:

| Repo | URL | Stack |
|------|-----|-------|
| Frontend | https://github.com/closerrrinteractive/closerrr-frontend | Flutter 3.19.5 / Dart 3.3.3 |
| Backend | https://github.com/closerrrinteractive/closerrr-backend | Node.js v24 + Express + Sequelize + MySQL |

### To clone on new machine:
```bash
git clone https://github.com/closerrrinteractive/closerrr-frontend.git
git clone https://github.com/closerrrinteractive/closerrr-backend.git
```

---

## 🔍 CODE AUDIT FINDINGS (Already Done)

### Backend — ~85-90% COMPLETE ✅
The backend is built in Node.js with Express + Sequelize ORM + MySQL.

**What's fully built:**
- Auth system (email/password + OTP + Google Sign-in + Apple Sign-in + JWT)
- User & Profile system (Fan role, Influencer/Creator role, Admin role)
- Real-time Chat / Messaging (40KB controller! WebSocket via Socket.IO, message seen receipts, starred messages, replies, media sharing)
- Subscription system (subscription plans, user subscriptions, transactions)
- Cashfree payment integration (order creation, webhooks)
- Cashfree payout system (beneficiary management, payout transfers)
- Firebase push notifications (FCM, per-user notification settings)
- Google Play subscription verification + webhook (PubSub)
- Apple App Store subscription verification
- Stories (create, like, delete)
- Events (create, edit, delete, cron jobs)
- Explore / Discovery
- Admin panel (user management, reports, bans)
- FAQ system
- Block/Report system
- Media/Image model (S3 storage)
- 40+ database migration files (complete schema)
- Socket.IO server

**What needs work:**
- Live streaming (basic models exist but full implementation pending)
- Connecting to production services (AWS, Cashfree production, etc.)
- Deployment to production server

### Frontend — Flutter App, ~75% COMPLETE ✅
**Structure:**
```
lib/
├── main.dart
├── firebase_options.dart
├── core/
│   ├── config/ (helpers.dart, responsive.dart, extension.dart)
│   ├── services/ (http_service.dart, socket_services.dart, routing_service.dart, etc.)
│   ├── themes/
│   └── utils/
│       └── api_string.dart  ← IMPORTANT: This is where the backend URL is configured
├── services/ (chat, events, explore, live stream, settings, in-app purchase)
└── src/
    ├── controller/ (auth, chat, live, events, explore, subscription, etc.)
    ├── models/ (auth, chat, events, explore, setting, showcase)
    └── view/
        ├── screens/ (auth, chat, dashboard, events, explore, live_stream, onboarding, settings)
        ├── widgets/
        └── popup/
```

**Key Flutter Dependencies (from pubspec.yaml):**
- `get` (GetX state management)
- `dio` (HTTP client)
- `socket_io_client` (real-time chat)
- `firebase_core`, `firebase_messaging` (push notifications)
- `google_sign_in`, `sign_in_with_apple` (social auth)
- `in_app_purchase`, `in_app_purchase_storekit` (subscriptions)
- `stream_video`, `stream_video_flutter` (live streaming - GetStream.io)
- `flutter_chat_ui`, `flutter_chat_core` (chat UI)
- `just_audio`, `record`, `audio_waveforms` (audio in chat)
- `video_player`, `video_thumbnail`, `video_compress` (video in chat)
- `image_picker`, `flutter_image_compress` (media)
- `shared_preferences` (local storage)
- `pin_code_fields` (OTP input)
- Flutter SDK: `>=3.6.2 <4.0.0`
- Note: Uses FVM (.fvmrc exists) — Flutter Version Manager

**Current Backend URL in Flutter (api_string.dart):**
```dart
static const String baseUrl = 'https://app.closerrr.com/closerrr/api/v1/';
static const String imageUrl = 'https://app.closerrr.com/closerrr/';
static const String socketUrl = 'https://app.closerrr.com/';
static const String s3ImageUrl = 'https://closerrr-chat-media.s3.us-east-1.amazonaws.com/';
```
→ This URL (`app.closerrr.com`) was the OLD production server. For local dev, it needs to be changed to `http://localhost:5253/api/v1/`

---

## ⚙️ ENVIRONMENT VARIABLES NEEDED (backend .env)

The `.env` file is NOT in the repo (gitignored). It must be created from scratch on new machine.

**Here is the complete template — fill in CHANGE_ME values:**

```env
# ---------- Server ----------
NODE_ENV=development
DEV_PORT=5253

# ---------- Database (Local MySQL) ----------
DEV_USERNAME=root
DEV_PASSWORD=CHANGE_ME_YOUR_MYSQL_ROOT_PASSWORD
DEV_DB=closerrr
DEV_HOST=localhost
DEV_DIALECT=mysql

# ---------- Production Database (AWS RDS — for later) ----------
PROD_USERNAME=CHANGE_ME
PROD_PASSWORD=CHANGE_ME
PROD_DB=closerrr
PROD_HOST=CHANGE_ME
PROD_DIALECT=mysql
PROD_PORT=3306

# ---------- JWT Secrets (ALREADY GENERATED — use these) ----------
ACCESS_TOKEN_SECRET=a6743c783116120aa6d4136bf554c6e0b8a4f0ba4902ebfafe75e8f858323a70652c593cf4db66fd8805f8c3ba105b354e4857b28764def7b43b7238b920f847
REFRESH_TOKEN_SECRET=fca93f2aff7fffd66c529afb5006259d3481bca968443f1013e2fb8395b3805c1646f8941e7aa0f563fdd2d38e699c356e1dc0343a3d591a650bc6c00ca08121

# ---------- AWS S3 (Media Storage) ----------
AWS_ACCESS_KEY_ID=CHANGE_ME
AWS_SECRET_ACCESS_KEY=CHANGE_ME
AWS_ACCESS_TOKEN=CHANGE_ME
S3_CHAT_BUCKET_NAME=closerrr-chat-media

# ---------- Google Auth ----------
GOOGLE_CLIENT_ID=CHANGE_ME

# ---------- Apple Auth ----------
APPLE_CLIENT_ID=CHANGE_ME
APPLE_ISSUER_ID=CHANGE_ME
APPLE_KEY_ID=CHANGE_ME
APPLE_SHARED_SECRET=CHANGE_ME

# ---------- Cashfree Payments ----------
CASHFREE_BASE_URL=https://sandbox.cashfree.com
CASHFREE_CLIENT_ID=CHANGE_ME
CASHFREE_CLIENT_SECRET=CHANGE_ME
CASHFREE_API_VERSION=2023-08-01

# ---------- GetStream.io (Live Streaming) ----------
GETSTREAMIO_SECRET=CHANGE_ME
```

**Also needed (NOT in .env — separate file):**
- `serviceAccountKey.json` → Download from Firebase Console → Place at root of `closerrr-backend/`

---

## 🏢 THE TWO-COMPANY SITUATION

| Account | Company to use | Status |
|---------|---------------|--------|
| Apple Developer ($99/yr) | **Shark Brews International** | Keep — already paid, valid |
| Google Play Console ($25) | **Shark Brews International** | Keep — already paid, valid |
| AWS | **Closerrr Interactive** | Fresh setup |
| Firebase | **Closerrr Interactive** | Check if closerrr-56695 is accessible; if not, create fresh |
| Cashfree | **Closerrr Interactive** | Fresh setup |
| GetStream.io | **Closerrr Interactive** | Fresh setup |

**This is 100% fine and common practice.** Apple/Google don't know or care what backend services you use. They are completely independent.

---

## 🖥️ MAC SETUP — COMPLETE CHECKLIST (Fresh Machine)

This machine is BRAND NEW. Install everything in this order:

### Step 1: Homebrew (Mac package manager — install this first)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Step 2: Git
```bash
brew install git
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

### Step 3: Node.js (via nvm — Node Version Manager)
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
# Restart terminal then:
nvm install 20
nvm use 20
```

### Step 4: MySQL (local database)
```bash
brew install mysql
brew services start mysql
mysql_secure_installation
# Set root password, remember it — put it in .env as DEV_PASSWORD
```

### Step 5: FVM (Flutter Version Manager — the project uses .fvmrc)
```bash
brew tap leoafarias/fvm
brew install fvm
fvm install 3.19.5
fvm global 3.19.5
```

### Step 6: Xcode
- Open App Store on Mac
- Search "Xcode" → Install (it's ~8GB, takes time)
- After install: `sudo xcode-select --switch /Applications/Xcode.app`
- Accept license: `sudo xcodebuild -license accept`

### Step 7: Android Studio
- Download from: https://developer.android.com/studio
- Install → during setup, install Android SDK
- Then run: `flutter doctor --android-licenses`

### Step 8: CocoaPods (iOS dependency manager)
```bash
sudo gem install cocoapods
```

### Step 9: Clone repos
```bash
mkdir ~/Workspace
cd ~/Workspace
git clone https://github.com/closerrrinteractive/closerrr-frontend.git
git clone https://github.com/closerrrinteractive/closerrr-backend.git
```

### Step 10: Backend setup
```bash
cd ~/Workspace/closerrr-backend
npm install
# Create .env file (use template above)
# Create MySQL database:
mysql -u root -p -e "CREATE DATABASE closerrr;"
# Run all 40+ migrations:
npx sequelize-cli db:migrate
# Seed roles:
npx sequelize-cli db:seed:all
# Start the server:
npm start
# Should say: Server listening on port 5253
```

### Step 11: Frontend setup
```bash
cd ~/Workspace/closerrr-frontend
fvm flutter pub get
# Open in VS Code or Android Studio
# Change api_string.dart baseUrl to local for dev:
# static const String baseUrl = 'http://localhost:5253/api/v1/';
```

### Step 12: Flutter Doctor check
```bash
flutter doctor -v
# Fix any issues it reports
```

---

## 🗺️ 7-10 DAY LAUNCH PLAN

### Day 1-2: Mac Setup + Database
- Install all tools above
- Get MySQL running
- Run migrations
- Get backend server running on port 5253
- Verify API endpoints work (test with Postman or curl)
- Fill in all CHANGE_ME values in .env

### Day 3-4: Connect & Fix Backend
- Set up Firebase (download serviceAccountKey.json)
- Set up AWS S3 bucket + IAM credentials
- Set up Cashfree sandbox credentials
- Set up Google OAuth Client ID
- Fix any broken API endpoints
- Test: signup → OTP → login → profile → chat

### Day 5-6: Flutter Frontend
- Change backend URL to local
- Run app on simulator
- Test all screens end to end
- Fix UI bugs
- Test on real iPhone and Android device

### Day 7-8: Production Deployment
- Set up AWS EC2 or Elastic Beanstalk for backend
- Set up AWS RDS MySQL for production database
- Configure domain (app.closerrr.com) to point to new server
- Deploy backend
- Set up SSL certificate (Let's Encrypt or AWS Certificate Manager)
- Update Flutter app to point to production URL

### Day 9-10: App Store Submission
- Build iOS release: `flutter build ipa`
- Upload to App Store Connect via Xcode
- Set up TestFlight for testing
- Submit for App Store review (takes 1-3 days)
- Build Android release: `flutter build appbundle`
- Upload to Google Play Console
- Submit for review

---

## 🔑 CREDENTIALS TO GATHER (Action Items for User)

### Firebase (go to console.firebase.google.com):
1. Sign in with Closerrr Interactive email
2. Check if project "closerrr-56695" exists
3. If yes: Settings → Service Accounts → Generate new private key → Download JSON
4. If no: Create new project → name it "closerrr" → repeat step 3
5. Rename downloaded file to `serviceAccountKey.json`
6. Place it in `closerrr-backend/` root folder

### AWS (go to console.aws.amazon.com):
1. Sign in with Closerrr Interactive email
2. Create free account if needed
3. Go to IAM → Users → Create User
4. Attach policy: `AmazonS3FullAccess`
5. Create access key → Download CSV with Key ID + Secret
6. Go to S3 → Create bucket named `closerrr-chat-media` → region: `us-east-1`
7. Make bucket public (for media access)

### Cashfree (go to merchant.cashfree.com):
1. Sign in / create account with Closerrr Interactive email
2. Go to Developers → API Keys
3. Copy Client ID and Client Secret
4. Start with TEST mode (sandbox)

### GetStream.io (go to getstream.io):
1. Create account
2. Create new app
3. Copy the Secret key from dashboard

### Google OAuth (go to console.cloud.google.com):
1. Sign in with Closerrr Interactive email
2. Create new project OR select existing
3. Enable Google Sign-In API
4. APIs & Services → Credentials → Create OAuth 2.0 Client ID
5. Application type: Android (add package name: com.sharkbrewsinternational.closerrr)
6. Copy Client ID

---

## 📝 IMPORTANT CODE NOTES

### 1. OTP System
The backend generates OTPs but DOES NOT send them via SMS. The OTP is stored in DB only. In dev, use OTP `11111` as master bypass. For production, need to integrate Twilio or similar SMS provider.

### 2. File Storage
Currently backend saves files locally to `public/` folder. For production, this needs to be switched to AWS S3 (the controller has S3 code commented in some places). AWS S3 bucket `closerrr-chat-media` is already referenced in the Flutter app.

### 3. Live Streaming
Uses **GetStream.io** (stream_video Flutter package). Backend generates JWT tokens for stream sessions. The live streaming UI exists in Flutter (call_stream.dart, live_stream screens). Backend has basic models. Need GetStream.io API key/secret.

### 4. Database
- Uses **MySQL** (not PostgreSQL — despite database.md suggesting otherwise)
- Sequelize ORM
- 40+ migration files covering: users, profiles, roles, chat, messages, stories, subscriptions, transactions, payouts, beneficiaries, live streams, events, notifications, blocks, reports, FAQs, OTPs
- Role IDs: Admin=1, Fan=2, Influencer(Creator)=3

### 5. Socket.IO
- Path: `/socket-server`
- Auth via JWT token
- Events: joinUserRoom, joinChatRoom, sendMessage, newMessage, badge_update, startLiveStream, endLiveStream, joinLiveStream, addCommentInLiveStream

### 6. Subscription Flow
- Fan pays via Cashfree → transaction recorded → subscription activated
- For iOS: StoreKit / in_app_purchase → Apple verifies → backend webhook updates subscription
- For Android: Google Play Billing → Google PubSub → backend webhook updates subscription

---

## 🗂️ KEY FILE LOCATIONS

### Backend
```
closerrr-backend/
├── index.js                    ← Entry point, server setup
├── .env                        ← NOT IN REPO - create manually
├── serviceAccountKey.json      ← NOT IN REPO - download from Firebase
├── paths.js                    ← Path aliases
├── controllers/                ← Business logic
│   ├── auth_controller.js
│   ├── chat_controller.js      ← Biggest file (40KB)
│   ├── cashfree_controller.js
│   ├── subscription_controller.js
│   └── ...
├── core/
│   ├── constants/constants.js  ← App constants (Package name, Project ID, etc.)
│   ├── middleware/             ← Auth, fan, influencer middleware
│   └── services/              ← Firebase, JWT, Socket, Cashfree, AWS, Google, Apple
├── models/                     ← 25+ Sequelize models
├── migrations/                 ← 40+ database migrations
├── routes/                     ← All API routes
└── seeders/                    ← Database seeders (roles etc.)
```

### Frontend
```
closerrr-frontend/
├── lib/
│   ├── main.dart               ← Entry point
│   ├── firebase_options.dart   ← Firebase config (auto-generated)
│   ├── core/
│   │   ├── services/
│   │   │   ├── http_service.dart    ← All API calls
│   │   │   ├── socket_services.dart ← WebSocket connection
│   │   │   └── routing_service.dart ← Navigation (30KB!)
│   │   └── utils/
│   │       └── api_string.dart      ← ⚡ BACKEND URL CONFIG — change this for local dev
│   └── src/
│       ├── controller/         ← GetX controllers for all features
│       ├── models/             ← Data models
│       └── view/
│           └── screens/        ← All UI screens
├── android/
│   └── app/
│       └── google-services.json ← Firebase Android config (IN REPO)
├── pubspec.yaml                ← Flutter dependencies
└── .fvmrc                      ← Flutter version: use fvm
```

---

## ✅ WHAT WAS DONE ON WINDOWS MACHINE (before Mac)

1. ✅ Repos cloned and analyzed
2. ✅ Full code audit completed
3. ✅ Backend npm dependencies installed (470 packages)
4. ✅ `.env` file created with variable template
5. ✅ JWT secrets generated:
   - ACCESS: `a6743c783116120aa6d4136bf554c6e0b8a4f0ba4902ebfafe75e8f858323a70652c593cf4db66fd8805f8c3ba105b354e4857b28764def7b43b7238b920f847`
   - REFRESH: `fca93f2aff7fffd66c529afb5006259d3481bca968443f1013e2fb8395b3805c1646f8941e7aa0f563fdd2d38e699c356e1dc0343a3d591a650bc6c00ca08121`
6. ✅ PowerShell execution policy fixed (RemoteSigned)
7. ✅ Node.js v24.16.0 confirmed
8. ✅ Flutter 3.19.5 confirmed
9. ❌ MySQL not installed — needs to be done on Mac
10. ❌ Database migrations not run yet
11. ❌ Firebase not configured yet
12. ❌ AWS not configured yet
13. ❌ Cashfree not configured yet

---

## 🚀 FIRST THING TO DO ON MAC

When you open this on Mac, tell the AI:

> "Read closerrrcontext.md in the closerrr-frontend repo. That's the full context. Now let's start the Mac setup from Step 1."

The AI should then:
1. Verify it read the full document
2. Check what's already installed on the Mac (`brew`, `node`, `flutter`, `mysql`, `xcode`)
3. Install whatever is missing
4. Clone both repos
5. Set up MySQL + create database
6. Create .env file
7. Run migrations
8. Get the backend server running
9. Then move to Flutter setup

---

*Document created: June 15, 2026 | By: Antigravity AI*
*This document should be kept updated as progress is made.*
