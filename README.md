# CheapSkate

An iOS expense tracking app for setting monthly budgets, logging spending by category, and visualizing trends over time.

> Swift 5.0 &nbsp;|&nbsp; iOS 17.5+ &nbsp;|&nbsp; The Composable Architecture &nbsp;|&nbsp; Firebase

---

## Features

- **Expense logging** — categorized entries (Food, Gas, Groceries, Misc) with a custom `CurrencyTextField` for decimal input
- **Budget tracking** — monthly budget goal with real-time delta, daily average, and projected monthly spend
- **Charts** — SwiftUI Charts `BarMark` visualization grouped by category and date
- **Expense history** — entries grouped by month with per-period summaries
- **Authentication** — Firebase Auth with email/password, full registration validation (length, special character, confirmation match)
- **Onboarding** — multi-step flow for setting budget and selecting tracked categories

---

## Architecture

TCA throughout, with a root `AppReducer` scoping into `Login`, `Onboarding`, and `Expense` child reducers. The `Expense` feature further composes `ExpenseChart`, `ExpenseSummary`, and `ExpenseHistory` as scoped sub-reducers.

Networking is handled by an actor-based `APIManager` wrapping Firebase Realtime Database, injected via a custom `DependencyKey` alongside a `FirebaseAuthentication` client — keeping reducers decoupled from Firebase and straightforward to test with `TestStore`.

---

## Tests

Reducer tests cover login error handling, registration validation (5 cases), chart domain and aggregation logic, and budget/projection calculations.

---

## Stack

SwiftUI · The Composable Architecture · SwiftUI Charts · Firebase Auth · Firebase Realtime Database
