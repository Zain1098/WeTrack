# WeTrack — Product Assumptions & Design Decisions

This document formally records all design decisions, defaults, and minimal assumptions made during the analysis and development of **WeTrack**, adhering to the instruction: *"Never silently invent product requirements. If a requirement is missing, choose the safest minimal implementation and record the assumption in /docs/ASSUMPTIONS.md."*

---

### Assumption 1: App Name & Branding
* **Decision:** The application is named **WeTrack** (representing women and couples tracking reproductive health journeys together privately).
* **Styling Alignment:** Uses the **Tactile Clay Pastel** visual system created in Google Stitch ("Feminine Health Journey App UI"), featuring claymorphic cards, lavender `#8B5CF6`, blush `#F472B6`, and mint `#6EE7B7` accents.

### Assumption 2: State Management & Architecture
* **Decision:** We use **Flutter Riverpod** for state management, combined with **Clean Architecture** (Presentation, Domain, Data, Core).
* **Rationale:** Riverpod provides compile-safe, testable dependency injection, reactive state, and seamless unit testing for deterministic date calculation services.

### Assumption 3: Local Offline Storage Engine
* **Decision:** We use **Hive** or **Isar** (or structured local storage with SQLite / SharedPreferences for config) for offline-first data.
* **Rationale:** High performance, zero remote setup required for MVP, supports encrypted boxes for sensitive reproductive logs, and guarantees the app runs 100% offline.

### Assumption 4: Cycle Calculation Fallback Defaults
* **Decision:**
  - Default average cycle length during initial onboarding (if user does not customize) is **28 days**.
  - Default period duration is **5 days**.
  - Default luteal phase length assumed for calendar-based fertile window calculation is **14 days**.
  - In all cases, the UI explicitly notes: *"Estimated based on standard 28-day baseline. Will automatically adjust as you log cycles."*

### Assumption 5: Fertile Window Definition
* **Decision:** In accordance with American Society for Reproductive Medicine (ASRM) guidelines, the fertile window is modeled as **6 calendar days** (the 5 days leading up to estimated ovulation, plus the day of ovulation itself).
* **Rationale:** Aligns strictly with `03_MEDICAL_SAFETY_KNOWLEDGE.pdf` and avoids inaccurate broad fertile windows.

### Assumption 6: Pregnancy Due Date Calculation Method
* **Decision:**
  - Standard Naegele's rule equivalent: $\text{LMP} + 280\text{ days}$ (40 completed gestational weeks).
  - Trimesters:
    - 1st Trimester: Weeks 1–13 (up to 13w 6d)
    - 2nd Trimester: Weeks 14–27 (up to 27w 6d)
    - 3rd Trimester: Weeks 28–40+
  - If a user enters an ultrasound-confirmed due date, all gestational weeks and countdowns are derived backward from the clinician-provided due date ($\text{Gestational Age} = 280 - (\text{Due Date} - \text{Current Date})$).

### Assumption 7: Partner Sharing Mechanism in Offline MVP
* **Decision:** In the offline-first MVP, the partner sharing flow generates a local share summary / export configuration and QR code or pairing preview. True cloud peer-to-peer sync is stubbed behind a repository interface so that the MVP operates with zero paid backend or server infrastructure.
* **Rationale:** Respects `06_FLUTTER_ARCHITECTURE_AND_SECURITY.pdf` ("Free MVP Rule: No paid backend is required for the first prototype").

### Assumption 8: AI Service Integration
* **Decision:** `AIService` is implemented with a clean abstract contract (`sendMessage(context, question)`). For the MVP, a robust local educational rules-based assistant is provided as the default implementation, with ready-to-wire adapters for Gemini 1.5/2.0 API or OpenAI API via environment variables.
* **Rationale:** Ensures zero breakage when offline or when API keys are not supplied.

### Assumption 9: Emergency Guidance
* **Decision:** High-risk pregnancy symptoms (heavy bleeding, sudden severe vision blur, fluid leakage) prompt an immediate red alert modal with a universal dialer button (`tel:112` or configurable national emergency number) and advice to seek emergency care immediately.
