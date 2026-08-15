---
name: ubantu-dev
description: Standard operational skill for Ubantu Flutter Supabase project using strict Clean MVVM Architecture, zero comments, reusable components, post-task comprehensive audit, OOP models, and git safeguards.
---

# Ubantu Flutter Development Skill

This skill defines the operational standards and technical guidelines for building the **Ubantu** application for Brawijaya University (UB) students.

## Key Principles & Guidelines

### 1. Zero Comment Rule (STRICT)
- Never write any comments (`//`, `/* */`, `///`) in any `.dart` files.
- Self-documenting code with clear variable, function, class, and parameter names.

### 2. Clean MVVM + Clean Architecture Standard
Organize all files in `lib/` under strict Clean MVVM Architecture:
- `lib/components/`: Reusable UI widgets & design system tokens (`theme/`, `buttons/`, `inputs/`, `cards/`, `badges/`, `feedback/`).
- `lib/core/`: Application core (`config/`, `errors/`, `navigation/`, `utils/`).
- `lib/data/`: Data layer (`models/` DTOs, `repositories/` concrete implementations, `services/` BaaS/APIs).
- `lib/domain/`: Domain logic layer (`models/` domain entities, `repositories/` abstract contracts, `usecases/` business commands).
- `lib/presentation/`: Presentation layer (`viewmodels/` Provider state controllers, `views/` pure UI screens).

### 3. Post-Task Comprehensive Audit Protocol
Always run after completing any task:
1. `flutter analyze` -> Must pass with 0 errors, 0 warnings, 0 lints.
2. `flutter test` -> Must pass 100% of unit and widget tests.
3. Zero Comment Audit -> Ensure no comments were inserted into `.dart` files.
4. Clean MVVM Architecture Audit -> Verify layer compliance (`components/`, `core/`, `data/`, `domain/`, `presentation/`).
5. Update `todo.md` immediately with completed task details.
6. Git Push Safeguard -> Never push to GitHub without explicit user comment approval.
