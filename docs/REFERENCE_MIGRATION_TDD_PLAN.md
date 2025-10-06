### wrdlHelper Reference-Migration Bolt-on Plan (TDD)

- **Goal**: Incrementally migrate algorithm behavior toward the reference (higher success rate, lower average guesses) as a bolt-on, guarded by feature flags. No rewrites; keep existing interfaces stable.
- **Approach**: Test-Driven Development, dark-launch via flags, progressive tightening of quality gates, minimal code edits per step.
- **Branch**: `perf/reference-migration`

---

### Guiding principles

- **Bolt-on, not rewrite**: Add new behavior behind flags; default remains current behavior.
- **TDD-first**: Write failing tests/benches, then implement the smallest change to pass.
- **Observability**: Temporary debug/metrics toggles for candidate/entropy inspection.
- **Progressive rollout**: Gradually tighten success-rate and average-guess targets.

---

### Phase 0 — Guardrails and toggles (foundation)

- [ ] Add runtime/config flags (Dart + Rust) to toggle:
  - [ ] `referenceMode` (preset)
  - [ ] `includeKillerWords`
  - [ ] `candidateCap` (int)
  - [ ] `earlyTerminationEnabled` (bool) and `earlyTerminationThreshold` (f64)
  - [ ] `entropyOnlyScoring` (bool)
- [ ] Plumb flags through FFI (`wrdlHelper` functions) without changing defaults.
- [ ] Add debug logging toggle for candidate list size and top 5 scores.
- Tests (write first):
  - [ ] Config/FFI roundtrip tests (Dart ⇄ Rust) prove values are applied.
  - [ ] Default-off behavior snapshot (no changes to suggestions).
- Acceptance: All tests pass with flags off; toggles compile and are readable in Rust.

Files likely touched (minimal edits): `wrdlHelper/lib/services/ffi_service.dart`, `wrdlHelper/wrdlHelper/rust/src/api/wrdl_helper.rs`, `wrdlHelper/wrdlHelper/test/ffi_performance_test.dart` (or new tests)

---

### Phase 1 — Word list parity via FFI

- [ ] Ensure `WORD_MANAGER` holds full official lists loaded from Dart at startup in tests/benches; remove tiny hardcoded lists from hot paths.
- Tests (write first):
  - [ ] Counts match assets exactly (answers ~2,315; guesses ~14,8xx) and are uppercase/normalized.
  - [ ] Benchmark fixture verifies no panic with full lists.
- Acceptance: Full lists resident in Rust; default behavior unchanged when flags off.

---

### Phase 2 — Curated "killer" words (behind flag)

- [ ] Add curated list to candidate generation when `includeKillerWords` is true (e.g., SLATE, CRANE, TRACE, RAISE, ROATE, ADIEU, PSYCH, GLYPH, VOMIT, JUMBO, ZEBRA, etc.).
- Tests (write first):
  - [ ] Candidate set includes all curated words when flag is on.
  - [ ] Entropy of curated words exceeds typical suspects in classic traps (e.g., MATCH/PATCH/LATCH/HATCH scenario).
- Acceptance: Candidate pool expands correctly; performance still within test time limits.

---

### Phase 3 — Candidate pool controls

- [ ] Make `candidateCap` and `earlyTerminationEnabled/Threshold` configurable.
- [ ] Add `referenceMode` preset: killers on, early termination off, large/unbounded cap.
- Tests (write first):
  - [ ] Preset toggling switches behavior deterministically.
  - [ ] Latency guard tests for default (non-reference) preset remain green.
- Acceptance: Flip between presets in tests without interface changes.

---

### Phase 4 — Scoring path: entropy-only

- [ ] Add pure-entropy path (statistical weight 0), selectable via `entropyOnlyScoring`.
- Tests (write first):
  - [ ] Unit tests for entropy computation against known distributions.
  - [ ] Given fixed remaining sets, entropy-only picks the highest-entropy candidate.
- Acceptance: Turning on entropy-only improves benchmark metrics (see Phase 6) without breaking defaults.

---

### Phase 5 — Filtering parity (greens/yellows/grays)

- [ ] Align gray counts with known-letters constraints (duplicate handling) to match reference semantics.
- Tests (write first):
  - [ ] Tricky duplicate cases (e.g., repeated letters, mixed colors) mirror reference outcomes.
  - [ ] Existing filtering tests remain green.
- Acceptance: Parity suite passes; no regressions.

---

### Phase 6 — Benchmark parity and quality gates

- [ ] Port lightweight benchmark stats to Rust and expose to Dart for test assertions.
- [ ] Add fast sample tests: 200–500 random games using full lists under `referenceMode`.
- Targets (ratchet up over time):
  - [ ] SR ≥ 96%, avg guesses ≤ 4.2
  - [ ] SR ≥ 98%, avg guesses ≤ 3.9
  - [ ] SR ≥ 99.5%, avg guesses ≤ 3.7
- CI gates:
  - [ ] New job runs the fast benchmark suite and enforces the current targets.
- Acceptance: CI green at each ratchet; print guess distribution and top candidates for diagnostics.

---

### Phase 7 — Progressive rollout

- [ ] Default enable: `includeKillerWords`, increased `candidateCap`.
- [ ] Staged enable: `entropyOnlyScoring` and `referenceMode` in CI/bench, then in prod.
- [ ] Lock final thresholds once stable.
- Acceptance: Benchmarks consistently meet final targets; no user-facing regressions.

---

### Phase 8 — Documentation and cleanup

- [ ] Update `docs/IMPLEMENTATION_COMPLETE.md` with migration flags, how to toggle, and results.
- [ ] Remove dead/legacy code guarded by flags once targets are achieved.
- Acceptance: Clean docs, minimal surface area, flags consolidated with sane defaults.

---

### How to run (local)

```bash
# From repo root
just test || ./wrdlHelper/run_tests.sh || flutter test

# Run benchmark tests only (example)
flutter test wrdlHelper/test/game_simulation_benchmark_test.dart -r expanded

# Example env toggles (to be added in Phase 0)
WRDL_REFERENCE_MODE=true \
WRDL_INCLUDE_KILLERS=true \
WRDL_ENTROPY_ONLY=true \
flutter test wrdlHelper/test/comprehensive_performance_test.dart -r expanded
```

---

### Definition of Done (per increment)

- Tests written first and failing; smallest code change to pass.
- Default behavior unchanged unless explicitly staged.
- Benchmarks meet the current ratcheted targets in CI.
- Docs updated for any new flag or observable behavior.

---

### Rollback plan

- Since all changes are behind flags/presets, rollback is immediate: turn flags off.
- If code changes are implicated, revert the specific commit on `perf/reference-migration` and re-run CI.


