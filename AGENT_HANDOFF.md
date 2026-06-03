# Agent handoff — Rust_Julia_FFI_Flutter_Template

## Purpose

This repo is a **production-ready template** for Flutter-Rust-Julia FFI integration. It demonstrates high-performance foreign function interfaces with a working Wordle solver (wrdlHelper) as the reference implementation.

**CRITICAL:** This project has **fragile FFI bindings** between Flutter, Rust, and iOS/macOS. Changes to build configurations, Podfile, Cargo.toml, flutter_rust_bridge.yaml, or Xcode project files can break the entire stack. The FFI setup took significant effort to stabilize.

**Sync:** This repo uses a **manual copy** approach for the agentic layer (no upstream remote). When AgenticTemplate updates, manually copy `.cursor/` skills/rules — never merge, never risk touching build files.

## Source of truth

- **Scope / sprints:** [PM_PLAN.md](PM_PLAN.md) (create if needed)
- **Architecture:** [docs/COMPREHENSIVE_ARCHITECTURE.md](docs/COMPREHENSIVE_ARCHITECTURE.md)
- **Setup:** [docs/SETUP_GUIDE.md](docs/SETUP_GUIDE.md)
- **Testing strategy:** [docs/TESTING_STRATEGY.md](docs/TESTING_STRATEGY.md)
- **Skills:** [.cursor/skills/](.cursor/skills/) — DEV_GUIDE.md, TEST_TDD.md, DESIGN_SYSTEM.md, techwriter, tester, code-reviewer, code-quality-gate, tech-lead, tech-debt-evaluator, eval-engineer, risk-manager, release-manager, security-reviewer, incident-triager, green-and-clean, context-bootstrapper, session-summarizer, pm-governance, ui-ux, game-readiness, visual-match, github-feature-workflow

## High-risk files (DO NOT CHANGE without understanding FFI implications)

| File/Directory | Risk | Why |
|----------------|------|-----|
| `wrdlHelper/ios/` | **CRITICAL** | Xcode project, Podfile, build phases — breaks iOS build |
| `wrdlHelper/rust/Cargo.toml` | **CRITICAL** | Rust dependencies, FFI bridge config |
| `wrdlHelper/flutter_rust_bridge.yaml` | **CRITICAL** | FFI code generation config |
| `wrdlHelper/rust_builder/` | **HIGH** | Cargokit integration for building Rust |
| `wrdlHelper/pubspec.yaml` | **HIGH** | Flutter dependencies, FFI plugin references |
| `wrdlHelper/lib/src/rust/` | **HIGH** | Generated FFI bindings — do not edit manually |

## Pod (agents always working)

- **Techwriter:** Use when editing README, AGENT_HANDOFF, or docs/.
- **Tester:** Run tests after changes. See TEST_PLAN.md and commands below.
- **Handoff (mandatory):** When the user wants a handoff, run code review (code-reviewer), tech debt (tech-debt-evaluator), and tests; record in the handoff note. See [.cursor/rules/handoff-checklist.mdc](.cursor/rules/handoff-checklist.mdc).

## Current state

- **Template:** Production-ready Flutter-Rust-Julia FFI with wrdlHelper reference implementation.
- **FFI Status:** 100% working — all Rust functions accessible from Flutter.
- **Test Status:** 19/19 Rust tests passing, Flutter FFI tests passing.

## Run and test

```bash
# Navigate to Flutter project
cd wrdlHelper

# Install dependencies
flutter pub get

# Run the app
flutter run

# Tier 1: Flutter unit tests (uses algorithm-testing word list for speed)
flutter test

# Tier 1: Rust unit tests
cd rust && cargo test && cd ..

# Tier 1: All tests with coverage
flutter test --coverage

# Tier 2: Integration tests (requires device/simulator)
flutter test integration_test/

# Build for iOS (requires macOS + Xcode)
flutter build ios --release

# Build for macOS
flutter build macos --release
```

**Merge-ready gate:** `flutter test && cd rust && cargo test && cd ..`

## Conventions

- **FFI changes:** Before changing any FFI-related files, read [docs/SETUP_GUIDE.md](docs/SETUP_GUIDE.md) and understand the flutter_rust_bridge workflow.
- **Rust API changes:** After modifying `rust/src/api/*.rs`, regenerate FFI bindings with `flutter_rust_bridge_codegen generate`.
- **Docs:** Use the **techwriter** skill when editing README, AGENT_HANDOFF, or docs/.
- **Tests:** Black-box; run `flutter test` and `cargo test` after changes. Use the algorithm-testing word list (1,273 words) for fast tests — see [docs/TESTING_STRATEGY.md](docs/TESTING_STRATEGY.md).

---

## Git workflow (how work lands on `main`)

1. **Integration branch:** `main`. All shipped product state should reflect what is merged here.
2. **Feature branches:** For larger slices, use `feature/<topic>` or `fix/<topic>`, then merge into `main`. See [.cursor/skills/github-feature-workflow/SKILL.md](.cursor/skills/github-feature-workflow/SKILL.md).
3. **Before push:** Run `flutter test && cd rust && cargo test && cd ..`. Do **NOT** push if FFI tests fail.
4. **Pull requests:** Optional — document your team's preference.
5. **After merge:** Delete the feature branch.

---

## Handoff protocol

When ending a session:

1. Run the handoff checklist (code review, tech debt, tests). See [.cursor/rules/handoff-checklist.mdc](.cursor/rules/handoff-checklist.mdc).
2. Update **PM_PLAN.md** (if you maintain one) when shipped scope changed.
3. Write a **local** session note: **`.cursor/handoff/NNNN-handoff-YYYY-MM-DD_HHmm.md`** (new monotonic `NNNN` each time).
4. Update **"Current state"** above only when it helps the next session.

---

## Syncing the agentic layer

This repo does **NOT** use an upstream git remote for AgenticTemplate (to protect the fragile FFI setup from accidental merges).

**To update skills/rules from AgenticTemplate:**

```bash
# 1. Clone or update AgenticTemplate separately
cd ~/Dev/AgenticTemplate && git pull

# 2. Manually copy .cursor/ directory (excludes build files)
cp -r ~/Dev/AgenticTemplate/.cursor/* ~/Dev/Rust_Julia_FFI_Flutter_Template/.cursor/

# 3. Review changes, adapt project-specific files:
#    - DEV_GUIDE.md (keep Rust/Julia/FFI content)
#    - TEST_TDD.md (keep flutter test / cargo test commands)
#    - always.mdc (keep project context)
#    - AGENT_HANDOFF.md (keep run/test section)

# 4. Commit the skill updates
git add .cursor/
git commit -m "Sync skills from AgenticTemplate (manual copy)"
```

**Why manual copy:** Git merge could accidentally include files that break the FFI setup. Manual copy of just `.cursor/` is surgical and safe.
