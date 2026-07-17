# Agent handoff — Rust_Julia_FFI_Flutter_Template

## Purpose

This repo is a **production-ready template** for Flutter-Rust-Julia FFI integration. It demonstrates high-performance foreign function interfaces with a working Wordle solver (wrdlHelper) as the reference implementation.

**CRITICAL:** This project has **fragile FFI bindings** between Flutter, Rust, and iOS/macOS. Changes to build configurations, Podfile, Cargo.toml, flutter_rust_bridge.yaml, or Xcode project files can break the entire stack. The FFI setup took significant effort to stabilize.

**Sync:** This repo uses a **manual copy** approach for the agentic layer (no upstream remote). When AgenticTemplate updates, manually copy `.cursor/` skills/rules and root SDD files — never merge, never risk touching build files. See [Syncing the agentic layer](#syncing-the-agentic-layer) below.

---

## Source of truth

- **Scope / sprints:** [PM_PLAN.md](PM_PLAN.md)
- **Architecture:** [docs/COMPREHENSIVE_ARCHITECTURE.md](docs/COMPREHENSIVE_ARCHITECTURE.md)
- **Setup:** [docs/SETUP_GUIDE.md](docs/SETUP_GUIDE.md)
- **Testing strategy:** [docs/TESTING_STRATEGY.md](docs/TESTING_STRATEGY.md)
- **Test plan:** [TEST_PLAN.md](TEST_PLAN.md)
- **Skills:** [.cursor/skills/](.cursor/skills/) — DEV_GUIDE.md, TEST_TDD.md, DESIGN_SYSTEM.md, techwriter, tester, code-reviewer, **code-quality-gate**, **tech-lead**, tech-debt-evaluator, eval-engineer, risk-manager, release-manager, security-reviewer, incident-triager, green-and-clean, context-bootstrapper, session-summarizer, pm-governance, ui-ux, game-readiness, visual-match, **github-feature-workflow**

## Green and clean operating model (how we work)

This template assumes a strict operating model aimed at **green and clean** delivery:

- **Green**: each change is verifiable against explicit acceptance criteria and validated at the appropriate tier.
- **Clean**: context is curated; durable state lives in tracked docs; handoffs are compressed and decision-first.

Skills that enforce this:

- [.cursor/skills/green-and-clean/SKILL.md](.cursor/skills/green-and-clean/SKILL.md)
- [.cursor/skills/context-bootstrapper/SKILL.md](.cursor/skills/context-bootstrapper/SKILL.md)
- [.cursor/skills/session-summarizer/SKILL.md](.cursor/skills/session-summarizer/SKILL.md)
- [.cursor/skills/eval-engineer/SKILL.md](.cursor/skills/eval-engineer/SKILL.md)

## Context hierarchy (what belongs where)

- **Level 1 — Project baseline**: `.cursor/rules/always.mdc`, `AGENT_HANDOFF.md`
- **Level 2 — Phase/feature**: `PM_PLAN.md`, `TEST_PLAN.md`
- **Level 3 — Task**: your current plan + acceptance criteria + verifiable steps
- **Level 4 — Session delta**: latest `.cursor/handoff/NNNN-handoff-YYYY-MM-DD_HHmm.md` (and/or `doc/handoff/NNNN-HANDOFF-YYYY-MM-DD_HHmm.md`) — highest `NNNN`, tie-break by timestamp

Token hygiene: prefer a small "Level 1 + Level 2 + one handoff note + current files" payload over transcript dumps.

## Risk discipline

Keep the top risks explicit and current:

- [RISKS.md](RISKS.md) — top 5 only (impact/likelihood/trigger/mitigation/rollback)

## Release / merge discipline

Keep "ship" criteria explicit and boring:

- [RELEASE.md](RELEASE.md) — merge-ready expectations and rollback posture

## Technical debt discipline

Track debt continuously and evaluate ROI:

- [.cursor/skills/tech-debt-evaluator/SKILL.md](.cursor/skills/tech-debt-evaluator/SKILL.md) — produces "Do first" items during handoff
- [TECH_DEBT.md](TECH_DEBT.md) — durable ranked backlog (promote persistent "Do first" items here)

## Incident / debugging discipline

When something breaks, use evidence-driven triage and keep it bounded:

- [.cursor/skills/incident-triager/SKILL.md](.cursor/skills/incident-triager/SKILL.md)
- [INCIDENTS.md](INCIDENTS.md) — what to capture (minimum) for handoff and prevention

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
- **Tester:** Run tests after changes. See [TEST_PLAN.md](TEST_PLAN.md) and commands below.
- **Handoff (mandatory):** When the user wants a handoff, run code review (code-reviewer), tech debt (tech-debt-evaluator), and tests; record in the handoff note. See [.cursor/rules/handoff-checklist.mdc](.cursor/rules/handoff-checklist.mdc).

## Current state

- **Template:** Production-ready Flutter-Rust-Julia FFI with wrdlHelper reference implementation.
- **SDD layer:** Synced from AgenticTemplate (June 2026) — skills, rules, governance files.
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

# Tier 1a: Rust unit tests
cd rust && cargo test && cd ..

# Tier 1b: Flutter unit tests (uses algorithm-testing word list for speed)
flutter test

# Tier 1b: All tests with coverage
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
- **Tests:** Black-box; run `flutter test` and `cargo test` after changes. Use the algorithm-testing word list (1,273 words) for fast tests — see [docs/TESTING_STRATEGY.md](docs/TESTING_STRATEGY.md). Prefer writing a failing test before new production code (TDD) where applicable.

---

## Git workflow (how work lands on `main`)

Document **your** team rules here and keep them in sync with what you run locally.

1. **Integration branch:** **`main`**. All shipped product state (PM_PLAN, roadmap checkboxes) should reflect what is merged here.
2. **Feature branches:** For larger slices, use `feature/<topic>` or `fix/<topic>`, then merge into `main`. See [.cursor/skills/github-feature-workflow/SKILL.md](.cursor/skills/github-feature-workflow/SKILL.md).
3. **Before push / merge-ready:** Run `flutter test && cd rust && cargo test && cd ..`. Do **NOT** push if FFI tests fail.
4. **After push — verify CI:** Agents do not get GitHub failure emails. When Actions exist, run `gh run watch --repo OWNER/REPO` (or `gh run list` + `gh run view --log-failed`) before declaring work done on `main`. See [.cursor/skills/github-feature-workflow/SKILL.md](.cursor/skills/github-feature-workflow/SKILL.md).
5. **Pull requests:** **Optional** — document your team's preference. If optional, direct push to `main` after green CI is still valid.
6. **After merge:** Delete the local feature branch; delete the remote feature branch if your flow created one.

---

## Handoff protocol

When ending a session:

1. Run the handoff checklist (code review, tech debt, tests). See [.cursor/rules/handoff-checklist.mdc](.cursor/rules/handoff-checklist.mdc).
2. Update **PM_PLAN.md** and your **product plan / roadmap** (if you maintain one under `doc/plan/` or similar) when shipped scope changed — that is what **`main`** should carry for product state.
3. Use [.cursor/skills/session-summarizer/SKILL.md](.cursor/skills/session-summarizer/SKILL.md), then write a **local** session note (gitignored by default): **`doc/handoff/NNNN-HANDOFF-YYYY-MM-DD_HHmm.md`** and/or **`.cursor/handoff/NNNN-handoff-YYYY-MM-DD_HHmm.md`** (new monotonic `NNNN` each time; never overwrite prior notes). Include Code review, Tech debt, Tests / coverage, Done this session, Next up. Use [.cursor/handoff/_template.md](.cursor/handoff/_template.md) as a starting point. See [.cursor/handoff/README.md](.cursor/handoff/README.md).
4. Update **"Current state"** above only when it helps the next session; keep **AGENT_HANDOFF** for process and commands, not epic inventories.


## Epic close (automatic)

When an epic's in-scope work is done, **do not wait for the user to ask**. Run [.cursor/rules/epic-close.mdc](.cursor/rules/epic-close.mdc) / pm-governance *Epic close*: **handoff checklist first**, then mark the epic complete in plan/status docs, close note, commit/push, summarize. See [.cursor/skills/pm-governance/SKILL.md](.cursor/skills/pm-governance/SKILL.md).
Anything the team must see on the remote should land in **PM_PLAN**, the **product plan**, **README**, or the **PR** — not only in gitignored handoff files.

---

## Syncing the agentic layer

This repo does **NOT** use an upstream git remote for AgenticTemplate (to protect the fragile FFI setup from accidental merges).

**To update skills/rules from AgenticTemplate:**

```bash
# 1. Clone or update AgenticTemplate separately
cd ~/Dev/AgenticTemplate && git pull

# 2. Manually copy .cursor/ directory (excludes build files)
cp -r ~/Dev/AgenticTemplate/.cursor/* ~/Dev/Rust_Julia_FFI_Flutter_Template/.cursor/

# 3. Copy root SDD governance files
cp ~/Dev/AgenticTemplate/{INCIDENTS,RISKS,TECH_DEBT,RELEASE}.md ~/Dev/Rust_Julia_FFI_Flutter_Template/

# 4. Review changes, adapt project-specific files:
#    - DEV_GUIDE.md (keep Rust/Julia/FFI content)
#    - TEST_TDD.md (keep flutter test / cargo test commands)
#    - always.mdc (keep project context)
#    - AGENT_HANDOFF.md (keep run/test section, merge new SDD sections)
#    - PM_PLAN.md, TEST_PLAN.md (adapt for Flutter/Rust commands)

# 5. Commit the skill updates
git add .cursor/ INCIDENTS.md RISKS.md TECH_DEBT.md RELEASE.md PM_PLAN.md TEST_PLAN.md doc/
git commit -m "Sync SDD layer from AgenticTemplate (manual copy)"
```

**Why manual copy:** Git merge could accidentally include files that break the FFI setup. Manual copy of just `.cursor/` and governance files is surgical and safe.

### What stays shared vs stack-specific

| Shared (sync from upstream)                | Stack-specific (keep yours)           |
| ------------------------------------------ | ------------------------------------- |
| Most skills (techwriter, tester, code-reviewer, code-quality-gate, tech-lead, etc.) | `DEV_GUIDE.md` (Rust/FFI architecture) |
| Rules (handoff-checklist, testing.mdc)     | `TEST_TDD.md` (flutter test / cargo test) |
| Handoff templates                          | `DESIGN_SYSTEM.md` (Flutter UI)       |
| Operating model skills (green-and-clean, etc.) | `always.mdc` (FFI project context) |
| Root SDD files (INCIDENTS, RISKS, TECH_DEBT, RELEASE) | `AGENT_HANDOFF.md` (run/test section, high-risk files) |
|                                            | `PM_PLAN.md`, `TEST_PLAN.md` (adapt commands) |
