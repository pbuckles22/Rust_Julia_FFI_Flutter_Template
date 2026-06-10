# Contributing to Rust + Julia + Flutter FFI Template

Thank you for contributing. This template uses **tracked documentation** as the source of truth — not chat history and not local handoff files alone.

## Start here (reading order)

1. [README.md](README.md) — what this template provides
2. **[docs/PROJECT_STATUS.md](docs/PROJECT_STATUS.md)** — current state, active branch, what's next
3. [AGENT_HANDOFF.md](AGENT_HANDOFF.md) — merge-ready gate, high-risk FFI paths, conventions
4. [docs/SETUP_GUIDE.md](docs/SETUP_GUIDE.md) — **read before touching FFI or build files**
5. [docs/TESTING_STRATEGY.md](docs/TESTING_STRATEGY.md) — Tier 1 / Tier 2 commands
6. [docs/COMPREHENSIVE_ARCHITECTURE.md](docs/COMPREHENSIVE_ARCHITECTURE.md) — system overview
7. [wrdlHelper/README.md](wrdlHelper/README.md) — reference app details

## Local session notes vs GitHub

| Location | On GitHub? | Purpose |
|----------|------------|---------|
| `docs/PROJECT_STATUS.md` | **Yes** | Human-readable current state — **update when milestones ship** |
| `AGENT_HANDOFF.md` → Current state | **Yes** | Maintainer + agent snapshot — keep in sync |
| `PM_PLAN.md` | **Yes** (if maintained) | Phase checklists |
| `.cursor/handoff/*-handoff-*.md` | **No** (gitignored) | Optional local session diary |
| `docs/handoff/*-HANDOFF-*.md` | **No** (gitignored by default) | Same — promote decisions to tracked docs |

**Norm:** If a decision affects what contributors build next, update `docs/PROJECT_STATUS.md` and `AGENT_HANDOFF.md` in the same PR — not only a gitignored handoff note.

## Development setup

### Prerequisites

- Flutter SDK 3.9.2+ (see `wrdlHelper/pubspec.yaml`)
- Rust 1.70+ (`rustup` recommended)
- **macOS + Xcode** for iOS builds and full FFI validation

### Clone and branch

```bash
git clone https://github.com/pbuckles22/Rust_Julia_FFI_Flutter_Template.git
cd Rust_Julia_FFI_Flutter_Template
git fetch origin
git checkout main   # or the branch named in PROJECT_STATUS
cd wrdlHelper
flutter pub get
```

### Test

```bash
cd wrdlHelper

# Tier 1 — Flutter
flutter test

# Tier 1 — Rust
cd rust && cargo test && cd ..

# Tier 2 — integration (device/simulator)
flutter test integration_test/
```

**Merge-ready gate:** `flutter test && cd rust && cargo test && cd ..`

## High-risk areas (read before editing)

| Path | Risk |
|------|------|
| `wrdlHelper/ios/` | CRITICAL — Xcode, Podfile |
| `wrdlHelper/rust_builder/` | HIGH — Cargokit |
| `wrdlHelper/flutter_rust_bridge.yaml` | CRITICAL — codegen config |
| `wrdlHelper/rust/Cargo.toml` | CRITICAL |
| `wrdlHelper/lib/src/rust/` | HIGH — **generated; never hand-edit** |

Before changing `wrdlHelper/rust/src/api/*.rs`: read [docs/SETUP_GUIDE.md](docs/SETUP_GUIDE.md), then regenerate:

```bash
flutter_rust_bridge_codegen generate
```

## Agentic layer sync

This repo uses **manual copy** from [AgenticTemplate](https://github.com/pbuckles22/AgenticTemplate) — **no git merge** (FFI fracture risk). See [AGENT_HANDOFF.md](AGENT_HANDOFF.md) → *Syncing the agentic layer*.

**Do not** git-merge this template into downstream products (e.g. MeowdokuHelper) without a dedicated FFI migration plan.

## Pull request expectations

- [ ] Scope matches PROJECT_STATUS or agreed issue
- [ ] Merge-ready gate green (tiers appropriate to your change)
- [ ] No secrets, credentials, or `.env` files
- [ ] If `rust/src/api/` changed: FRB bindings regenerated
- [ ] If a milestone shipped: update **docs/PROJECT_STATUS.md** and **AGENT_HANDOFF** *Current state*

## Questions

Open a GitHub issue (contribution template) or see [AGENT_HANDOFF.md](AGENT_HANDOFF.md).
