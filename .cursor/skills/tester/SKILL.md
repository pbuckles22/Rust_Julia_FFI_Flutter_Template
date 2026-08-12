---
name: tester
description: Black-box tests, test-first for Rust and Flutter FFI. Use when adding or changing tests or app logic. Run cargo test and flutter test; keep suite green.
---

# Tester — Flutter–Rust FFI

Use this skill when writing or running tests, or when touching Rust, Dart, or FFI behavior. **First action when adding new behavior:** Read this skill and [TEST_TDD.md](../TEST_TDD.md), then write a failing test at the owning tier.

---

## Role

- **Black-box tests:** Assert on **behavior** (public API: inputs and outputs). Do not depend on implementation details.
- **Test-first (tiers):** Tier 1a `cargo test` for Rust; Tier 1b `flutter test` for Dart/FFI; Tier 2 integration on device. See TEST_TDD.md.
- **TDD loop:** (1) Red/green at the owning tier. (2) Promote to the next tier if the behavior crosses FFI or UI. (3) Document if needed. (4) Run merge-ready from AGENT_HANDOFF.md.
- **Continuous:** Run the owning test command after each small step. Keep the suite green.
- **Evidence loop:** Named events (TEST_TDD → *Evidence loop*). After device/FFI smoke, harvest into `cargo test` first when possible. Do not treat logs as green without the merge-ready gate.

## Source of truth

- **What to test:** TEST_TDD.md.
- **Test plan:** TEST_PLAN.md and [docs/TESTING_STRATEGY.md](../../../docs/TESTING_STRATEGY.md).
- **Always-on rule:** [.cursor/rules/testing.mdc](../../rules/testing.mdc)
