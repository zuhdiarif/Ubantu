---
name: flutter-clean-mvvm
description: Mandatory global Clean MVVM + Clean Architecture blueprint and Universal Autonomous Improvement Loop Protocol for all Flutter projects.
---

# Universal Flutter Clean MVVM Architecture & Autonomous Loop Skill

This skill defines the mandatory architectural standard and **Universal Autonomous Improvement Loop Protocol** for ALL current and future Flutter projects.

---

## 1. Clean MVVM Architecture Overview

```
lib/
├── components/           # Reusable UI Components & Design Tokens (theme, buttons, inputs, cards, badges)
├── core/                 # Cross-Cutting Core Utilities & Navigation (di, errors, navigation, utils)
├── data/                 # Data Layer (models DTOs, repositoriesImpl, external services)
├── domain/               # Logic Layer / Domain (models entities, repository contracts, usecases)
└── presentation/         # UI Layer (MVVM: viewmodels State Management & views Pure UI Screens)
```

---

## 2. Universal Autonomous Improvement Loop Protocol (`[LAKSANAKAN ➔ SELESAI ➔ AUDIT]`)

Whenever the user requests a **loop saran** (improvement loop) in any project, execute the autonomous cycle iteratively:

1. **LAKSANAKAN (Execute)**:
   - Identify discrete architectural, state management, OOP, or code quality enhancements.
   - Write clean, modular, production-ready code under strict layer separation.
   - Enforce the **Zero Comment Rule** (`0` comments in `.dart` files).

2. **SELESAI (Complete)**:
   - Complete implementation, bind dependencies via `ServiceLocator` or `MultiProvider`.
   - Add/update automated unit and widget test cases.

3. **AUDIT (Verify & Audit)**:
   - Run `flutter analyze` ➔ Must achieve 0 errors, 0 warnings, 0 lints.
   - Run `flutter test` ➔ Must achieve 100% test pass rate across all test files.
   - Audit Zero Comment compliance across all source files.

---

## 3. Mandatory Summary Format with Benefits (`Keuntungan & Manfaat`)

Every time an autonomous loop run completes, the response **MUST** include a dedicated section summarizing the tangible benefits:

### Required Response Outline:
- **Rincian Eksekusi Loop**: Step-by-step breakdown of what was implemented.
- **Keuntungan & Manfaat**: Concrete benefits achieved (e.g., testability, decoupling, maintainability, type safety, performance).
- **Hasil Audit Komprehensif**: Compilation & test pass rate verification metrics.
