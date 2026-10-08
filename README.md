# 🌸 WeTrack — Menstrual Cycle, Fertility & Pregnancy Companion

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/State_Management-Riverpod_3.x-4B32C3" alt="Riverpod" />
  <img src="https://img.shields.io/badge/Backend-Supabase-3ECF8E?logo=supabase&logoColor=white" alt="Supabase" />
  <img src="https://img.shields.io/badge/Language-English_%26_Roman_Urdu-E91E63" alt="Localization" />
  <img src="https://img.shields.io/badge/UI_Style-Pastel_Claymorphism-E8DEF8" alt="Claymorphism" />
  <img src="https://img.shields.io/badge/License-Private-red" alt="License" />
</p>

---

## 📖 Overview

**WeTrack** is a modern, privacy-first women's reproductive health companion built with Flutter. Designed for individuals and couples, WeTrack supports every phase of the reproductive journey:
- **Menstrual Cycle Tracking** (ACOG-aligned follicular, ovulation & luteal predictions)
- **Conception & Fertility Planning** (TTC mode, fertile window, biomarker tracking)
- **Pregnancy Journey** (Automatic trimester transitions, weekly baby growth, ultrasound EDD countdown, and kick counter)

WeTrack combines deterministic medical guidelines with a comforting **3D Pastel Claymorphism** aesthetic, bilingual support (**English & Roman Urdu**), offline-first resilience, and cloud backup via **Supabase**.

---

## ✨ Key Features & Architectural Highlights

### 🔄 1. Intelligent Dual Dashboard & Mode Switching
- **Auto-Switching Architecture**: When pregnancy is confirmed (via a positive test modal or gestational input), the app automatically switches to **Hamal (Pregnancy) Mode** across all screens.
- **Zero Conflicting States**: Shuts down period countdowns and cycle alarms while in pregnancy mode, preventing confusing or distressing notifications.
- **Seamless Return**: Safely switch back to Cycle Tracking at any time with complete data integrity.

### ⚙️ 2. Interactive Cycle & Period Settings
- **Direct & Reactive Controls**: Located in both **Settings** and **Profile** screens.
- **Sliders & Circular Steppers**: Easily configure average cycle length (21–45 days) and period bleeding duration (2–10 days).
- **One-Tap Quick Presets**: Instant selection chips (`24 d`, `28 d (Normal)`, `30 d`, `32 d`, `35 d`).
- **Instant Recalculation**: Adjusting values immediately recalculates ovulation dates, fertile windows, and future period predictions across all providers and saves to both local cache and Supabase.

### 🔔 3. Notification Center & Exact Alarms
- **Cross-Platform Delivery**: Powered by `flutter_local_notifications` with Android exact alarm scheduling (`SCHEDULE_EXACT_ALARM`, `USE_EXACT_ALARM`) and web compatibility.
- **Interactive In-App Notification Center**: Accessible via top header bell icon with live unread badge. Features a dedicated **Inbox** with action buttons and clear-all capabilities.
- **Customizable Schedules**: Time pickers for morning & evening alerts, plus custom reminder items (medications, water, vitamins).
- **Instant Test Trigger**: Send a test notification at any time to verify system notifications.

### 🤖 4. Clinical AI Health Assistant (with Safety Guardrails)
- **Clinical Ethics First**: Refuses to deliver definitive medical diagnoses (such as PCOS) and instead equips users with clinician discussion questions.
- **Urgent Red-Flag Triage**: Immediately detects acute symptoms (e.g., severe unilateral pelvic pain, heavy hemorrhaging, fever > 38.5°C) and issues prominent urgent medical warnings.
- **Deterministic Context Awareness**: Seamlessly incorporates current cycle day, phase, and user goal without leaking raw personal information.
- **Dual Engine**: Google Gemini API powered, with an offline deterministic fallback engine (`LocalFallbackAIService`).

### 🌸 5. Bilingual Localization (English & Roman Urdu)
- **Native Roman Urdu**: Specifically tailored for South Asian cultural resonance and natural phrasing (e.g., *"Hamal Ka Mubarak Safar"*, *"Mahwari Ka Hisaab"*).
- **1-Tap Dynamic Switcher**: Instantly toggle between English and Roman Urdu from the header or settings without restarting the application.

### 🤝 6. Shohar / Partner Hub with 3D Claymorphism & Love Care Alerts
- **Dynamic Secure Pairing**: Personal unique pairing code generation with 1-tap copy/share and real partner code validation.
- **Cycle-Aware & Pregnancy Love & Care Alerts**:
  - Live guidance tailored to wife's active cycle phase (period cramp relief, fertile window TTC advice, PMS sensitive days, weekly baby development in pregnancy).
  - Practical Husband Do's & Don'ts checklist.
- **Husband Quick Love Reactions**:
  - 1-tap affectionate care buttons (*"❤️ Khayal rakhna apna"*, *"💊 Dawai le li?"*, *"☕ Garam chai laa doon?"*, *"🫂 Rest karo"*).
  - Triggers instant notifications in the wife's In-App Notification Center.
- **3-Tier Sharing Presets & Granular Privacy**:
  - **Full Care**: Complete joint sync for collaborative family planning.
  - **Essential Only**: Shares cycle dates and doctor appointments; keeps intimacy & symptoms strictly private.
  - **Custom**: Granular toggles for intimacy, period dates, symptoms, pregnancy, appointments, and private diary notes.
  - **Safety Disconnect**: 1-tap unpair/disconnect with confirmation dialog.

### 🛡️ 7. Comprehensive Data Sovereignty & Account Deletion
- **JSON Data Export**: Download an unencrypted complete export of all local health logs at any time.
- **Tier 1 — Clear Health Logs Only**: Wipes period entries, cycle records, symptoms, and appointments while preserving the user account and profile.
- **Tier 2 — Delete Account & All Data**: Complete, permanent wipe:
  - Deletes profile row from remote Supabase cloud database
  - Wipes all device storage and cached preferences
  - Signs out of Supabase Auth
  - Invalidates all in-memory Riverpod state and redirects cleanly to the login screen.

---

## 🛠️ Technology Stack

| Layer | Technology | Purpose |
| :--- | :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev) (3.x) | Cross-platform UI (Android, Web, iOS, Desktop) |
| **Language** | [Dart](https://dart.dev) (3.x) | Sound null-safety, async/await |
| **State Management** | [Flutter Riverpod](https://riverpod.dev) | Reactive, testable dependency injection |
| **Backend & Cloud** | [Supabase](https://supabase.com) | Authentication, PostgreSQL database sync |
| **Notifications** | `flutter_local_notifications` + `timezone` | Exact background alarms and scheduled push |
| **Local Storage** | `shared_preferences` | Resilient offline-first persistence |
| **Design System** | Custom Pastel 3D Claymorphism | Stress-reducing tactile UI with soft shadows |
| **Typography** | `GoogleFonts` (`Plus Jakarta Sans`) | Clean, accessible typography |

---

## 📁 Project Architecture

```text
lib/
├── core/
│   ├── constants/       # Clinical guidelines, disclaimers, and constants
│   ├── localization/    # AppStrings & language provider (English / Roman Urdu)
│   ├── theme/           # Pastel clay color palette, ClayTheme, and design tokens
│   ├── utils/           # Date calculations, formatting, and mathematical helpers
│   └── widgets/         # Reusable 3D clay cards, buttons, dials, and language toggles
├── data/
│   ├── models/          # Cycle, period, symptom, appointment, notification & profile models
│   ├── repositories/    # Offline-first LocalStorageRepository
│   └── services/        # Supabase AuthService, NotificationService & calculation engines
├── features/
│   ├── ai/              # Clinical AI service, Gemini API, and offline fallback
│   ├── appointments/    # Doctor appointment scheduling & reminders
│   ├── auth/            # Clay pastel Login, Sign Up, and OTP recovery screens
│   ├── calendar/        # Interactive cycle calendar with fertile phase highlights
│   ├── cycle/           # Period and symptom logging bottom sheets
│   ├── education/       # Women's health articles and reproductive guidance (Learn)
│   ├── fertility/       # Ovulation and fertility observation modals
│   ├── home/            # Adaptive home dashboard (Cycle vs. Pregnancy modes)
│   ├── insights/        # Trend charts, cycle variability, and health summaries
│   ├── notifications/   # In-app notification center modal and reminder settings
│   ├── onboarding/      # 4-step onboarding flow with cycle and metric sliders
│   ├── pregnancy/       # Trimester cards, baby growth milestones, and kick counter
│   ├── profile/         # Profile management, body metrics, and cycle settings modal
│   └── settings/        # App settings, PIN lock, partner sharing, cycle & delete options
└── main.dart            # App entry point, Supabase initialization & route resolution
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.12.2` or later)
- Chrome browser (for web testing) or Android device/emulator with Android 8.0+ (API 26+)

### Installation & Run

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Zain1098/WeTrack.git
   cd WeTrack
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run on Chrome (Web)**:
   ```bash
   flutter run -d chrome
   ```

4. **Run on Android device**:
   ```bash
   flutter run -d android
   ```

5. **Run test suite**:
   ```bash
   flutter test
   ```

6. **Analyze code**:
   ```bash
   flutter analyze
   ```

---

## ⚕️ Medical Guidance Notice

> **Important**: *WeTrack is designed as an informational health tracking and lifestyle companion tool. It is not a certified diagnostic medical device, nor does it provide clinical diagnoses or replace professional medical care. Calculations for fertile windows, ovulation, and period predictions are statistical estimates. Users should consult a qualified healthcare professional or physician for any reproductive health concerns, medical conditions, or pregnancy complications.*

---

## 📄 License
Private & Proprietary. All rights reserved.
