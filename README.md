# 🌸 WeTrack — Menstrual Cycle, Fertility & Pregnancy Companion

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/State_Management-Riverpod_3.x-4B32C3" alt="Riverpod" />
  <img src="https://img.shields.io/badge/Backend-Supabase-3ECF8E?logo=supabase&logoColor=white" alt="Supabase" />
  <img src="https://img.shields.io/badge/UI_Style-Pastel_Claymorphism-E8DEF8" alt="Claymorphism" />
  <img src="https://img.shields.io/badge/License-Private-red" alt="License" />
</p>

---

## 📖 Overview

**WeTrack** is a modern, privacy-focused women's health companion designed to empower individuals throughout every stage of their reproductive journey — from cycle tracking and ovulation prediction to pregnancy milestones. Built with Flutter, WeTrack combines medical-grade calculation accuracy with a comforting, warm **Pastel 3D Claymorphism** design aesthetic.

---

## ✨ Key Features

### 🎨 1. Pastel Claymorphism Aesthetic
- **Warm & Comforting Design**: Soft 3D clay cards, embossed pill-shaped inputs, and subtle pastel shadows designed to minimize stress and clinical anxiety.
- **Friendly Mascot**: Integrated 3D clay companion seamlessly resting atop interactive cards.
- **Micro-Animations**: Tactile button presses, smooth mode transitions, and gentle elevation changes.

### 🔐 2. Authentication & Data Security
- **Cloud Database Integration**: Secure user registration, login, and profile synchronization powered by **Supabase**.
- **Unified Auth Experience**: Seamless transition between **Login**, **Sign Up**, and **Forgot Password** screens without layout shifts.
- **Strict Privacy**: Data stored securely with no guest bypass; user accounts ensure cross-device consistency and personal data protection.
- **PIN App Lock**: Built-in 4-digit PIN security to safeguard sensitive health logs on the device.

### 🌸 3. Menstrual Cycle & Period Tracking
- **Deterministic Cycle Predictions**: ACOG-aligned cycle calculations tracking Follicular, Ovulation, and Luteal phases.
- **Daily Symptom & Mood Logging**: Record flow intensity, cramps, mood shifts, cravings, and customized notes.
- **Smart History**: Dynamically calculates averages from past cycles while gracefully handling anomalous or irregular lengths.

### 🌿 4. Fertility & Conception (TTC Mode)
- **Fertile Window Detection**: Pinpoint estimated ovulation days with high-probability conception indicators.
- **Biomarker Logs**: Track LH ovulation test strips, cervical mucus texture, basal body temperature (BBT), and intimate days.

### 🤰 5. Pregnancy Tracking & Milestones
- **Gestational Age & EDD**: Accurate countdown and weekly gestational calculations based on LMP (Last Menstrual Period).
- **Clinician Override**: Supports ultrasound and clinician date overrides for precise medical alignment.
- **Trimester Navigation**: Clear transitions between 1st, 2nd, and 3rd trimesters.
- **Appointments & Healthcare**: Schedule and monitor prenatal visits, clinician contacts, and clinic locations.

### 🤝 6. Granular Partner Sharing
- **Secure Code Pairing**: Generate private pairing codes to share milestones with partners.
- **Field-by-Field Control**: Enable or disable cycle dates, pregnancy updates, or symptom logs with individual privacy switches.

### 💾 7. Offline-First & Data Sovereignty
- **Instant Responsiveness**: Full offline accessibility backed by fast local storage.
- **Complete JSON Export**: Download a full unencrypted JSON backup of all personal health records at any time.
- **Total Erasure**: Complete, permanent data wipeout functionality with a single tap.

---

## 🛠️ Technology Stack

| Layer | Technology |
| :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev) (iOS, Android, Web, Desktop) |
| **Language** | [Dart](https://dart.dev) (Null Safety) |
| **State Management** | [Flutter Riverpod](https://riverpod.dev) |
| **Backend & Auth** | [Supabase](https://supabase.com) (Auth, PostgreSQL DB) |
| **Local Persistence** | `shared_preferences` (Offline-first local cache) |
| **Typography** | [Google Fonts](https://pub.dev/packages/google_fonts) (`Nunito`, `Fredoka`, `Outfit`) |
| **Vector Graphics** | [flutter_svg](https://pub.dev/packages/flutter_svg) |

---

## 📁 Project Structure

```text
lib/
├── core/
│   ├── constants/       # Medical guidelines and disclaimers
│   ├── theme/           # Pastel clay color palettes, typography, and ClayTheme
│   ├── utils/           # Date calculations and formatting helpers
│   └── widgets/         # Reusable 3D clay cards, pills, buttons, and dials
├── data/
│   ├── models/          # Cycle, period, symptom, appointment, and profile models
│   ├── repositories/    # Offline-first LocalStorageRepository
│   └── services/        # Supabase AuthService and deterministic calculation engines
├── features/
│   ├── ai/              # Medical safety guardrails and health AI assistant
│   ├── auth/            # Clay pastel Login, Sign Up, and Forgot Password screens
│   ├── calendar/        # Interactive cycle calendar
│   ├── cycle/           # Period and symptom logging bottom sheets
│   ├── education/       # Women's health articles and reproductive guidance
│   ├── fertility/       # Ovulation and fertility observation modals
│   ├── home/            # Dynamic home dashboard adapted to user goals
│   ├── insights/        # Historical trend charts and cycle statistics
│   ├── onboarding/      # Initial onboarding questions and goal selection
│   ├── pregnancy/       # Prenatal logs, milestones, and EDD management
│   └── settings/        # Privacy controls, PIN lock, partner sharing, and export
└── main.dart            # App entry point, Supabase initialization & route resolver
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.12.2` or later)
- Android Studio / VS Code with Flutter extension
- A device or emulator (Android / iOS / Desktop)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Zain1098/WeTrack.git
   cd WeTrack
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the application**:
   ```bash
   flutter run
   ```

4. **Execute test suite**:
   ```bash
   flutter test
   ```

---

## ⚕️ Medical Disclaimer

> **Important**: *WeTrack is designed as an informational tracking and lifestyle companion tool. It is not a certified diagnostic medical device, nor does it provide medical treatment or clinical diagnoses. Calculations for fertile windows, ovulation, and period predictions are statistical estimates. Users should consult a licensed healthcare professional or physician for any reproductive health concerns or medical guidance.*

---

## 📄 License
Private & Proprietary. All rights reserved.
