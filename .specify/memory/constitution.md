<!--
Sync Impact Report
- Version change: 1.0.0 → 1.0.1 (PATCH: wording clarification, no semantic change)
- Modified principles:
  - VII. Simplicity: "No ... MUST be added" rephrased to unambiguous "MUST NOT be added";
    justification rule now states it covers repository/domain layers and new packages alike.
- Added sections: none
- Removed sections: none
- Re-validated against user input: all supplied rules (doc comments, no inline comments,
  ask-don't-guess, existing structure, no UI tests, GetX, layered structure, Drift-only,
  error handling split, testing, code quality, simplicity) are already present in v1.0.0.
- Follow-up TODOs (carried over from 1.0.0):
  - RESOLVED: CLAUDE.md architecture line aligned with Principle II and now defers to this
    constitution.
  - Drift table classes currently live in lib/persistance/tables.dart; Principle III treats
    them as part of the database.dart schema definition.
  - pubspec.yaml still depends on sqflite; Principle III forbids new sqflite code only.
-->
# RepTrack Constitution

## Core Principles

### I. GetX State Management

- Every screen MUST have exactly one `GetxController` located in `lib/controllers/`.
- Controller state MUST be held in Rx fields (`.obs`, `Rx<T>`, `RxList`, etc.).
- Pages MUST read reactive state through `Obx`.
- Page-scoped controllers MUST be created with `Get.put`.
- App-wide singleton controllers MUST be registered in `lib/main.dart` with `permanent: true`.

Rationale: a single, predictable state pattern keeps screens uniform and controllers testable
without widget infrastructure.

### II. Layered Structure

- Code MUST be placed in one of: `lib/pages/` (screens), `lib/widgets/` (reusable UI),
  `lib/controllers/` (logic), `lib/persistance/` (data) or `lib/utils/` (shared helpers).
- Pages and widgets MUST NOT query the database directly; all data access goes through a
  controller.
- New code MUST follow the existing project structure and design principles rather than
  introducing parallel conventions.

Rationale: a flat, well-known layout makes it obvious where code belongs and keeps UI free of
persistence concerns.

### III. Drift-Only Persistence

- Drift is the only storage layer. New sqflite code MUST NOT be written.
- Schema changes MUST be made in `lib/persistance/database.dart` (including its table
  definitions), MUST be accompanied by a regenerated `database.g.dart`, and MUST include a
  schema migration with an incremented `schemaVersion`.
- Any new exercise kind MUST cover all three variants (strength, cardio and hybrid) in both the
  program tables and the set tables.

Rationale: one storage layer and explicit migrations protect existing user data on upgrade;
covering all variants prevents half-supported exercise types.

### IV. Error Handling Split

- Failures the user cannot fix MUST be reported via `AppErrorHandler.showSystemError`.
- Validation errors the user can fix MUST be reported via `AppSnackbar`.
- Exceptions MUST NOT be swallowed silently; every `catch` block MUST report, rethrow or
  otherwise explicitly handle the error.

Rationale: users get actionable feedback for their own mistakes and a consistent report for
system failures, while no error disappears unnoticed.

### V. Testing Discipline

- Changes to controller, persistence or utility logic MUST include tests in the matching
  `test/` subfolder (`test/controllers/`, `test/persistance/`, `test/utils/`).
- Every bug fix MUST include a regression test that fails without the fix.
- Tests MUST use the in-memory database provided by `test/test_helpers.dart`.
- UI (widget/integration) tests are NOT required.

Rationale: logic is where regressions hurt most; in-memory databases keep tests fast and
isolated.

### VI. Code Quality & Documentation

- Every class and method MUST have a brief `///` doc comment following Dart documentation
  conventions; public APIs MUST always be documented.
- Inline comments (`//` within method bodies or trailing code) MUST NOT be used.
- `dart format` MUST be run after every change.
- `const` constructors MUST be used wherever possible.
- `flutter analyze` MUST report no issues.

Rationale: doc comments explain intent at the API boundary; code inside methods should be clear
enough not to need narration.

### VII. Simplicity

- Repository or domain layers MUST NOT be added.
- New packages MUST NOT be added.
- An exception to either rule is allowed only when the reason it is needed is written down in
  the feature's plan (Complexity Tracking) before implementation.

Rationale: the app is small; extra abstraction and dependencies cost more than they return.

## Implementation Constraints

- If any information needed to implement a request is unknown or ambiguous, the implementer
  MUST ask for clarification instead of guessing. Assumptions MUST NOT be presented as facts,
  and APIs, files or behaviours that do not exist MUST NOT be invented.
- Tech stack: Flutter, Dart, GetX for state management and routing, Drift for persistence.

## Development Workflow

- After editing: run `dart format`, then `flutter analyze`, then `flutter test`.
- After schema changes: run
  `flutter pub run build_runner build --delete-conflicting-outputs` and commit the regenerated
  `database.g.dart` together with the migration.
- A change is complete only when formatting, analysis and tests all pass.

## Governance

- This constitution supersedes other development practices and guidance files. Where
  `CLAUDE.md` or other docs conflict with it, this constitution wins and the conflicting doc
  MUST be updated.
- Amendments are made via `/speckit-constitution`, MUST update the version and Last Amended
  date, and MUST describe the change in the Sync Impact Report.
- Versioning follows semantic versioning: MAJOR for removing or redefining a principle, MINOR
  for adding a principle/section or materially expanding guidance, PATCH for clarifications.
- Every plan (`/speckit-plan`) MUST pass a Constitution Check, and every review MUST verify
  compliance. Deviations MUST be justified in writing in the plan.

**Version**: 1.0.1 | **Ratified**: 2026-09-26 | **Last Amended**: 2026-09-26
