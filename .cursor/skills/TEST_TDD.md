# TEST_TDD — Rust_Julia_FFI_Flutter_Template

## How to test

- **Black-box:** Assert on behavior (public API: inputs and outputs). Do not depend on implementation details.
- **Continuous:** Run tests after adding or changing logic; keep the suite green.
- **Three-tier:** Rust unit tests (fastest), Flutter unit tests (fast), integration tests (slowest).

See [docs/TESTING_STRATEGY.md](../../docs/TESTING_STRATEGY.md) for the algorithm-testing word list approach.

---

## TDD for this project

**Default:** Do not merge production changes until the right tier(s) have **failing test → passing test** for the behavior you are adding or changing.

### Tier 1a: Rust unit tests (fastest)

Use for pure Rust logic (algorithms, data processing, word filtering).

```bash
cd wrdlHelper/rust
cargo test
```

1. **Red** — Add a test in the `#[cfg(test)]` module that fails.
2. **Green** — Implement until `cargo test` passes.

### Tier 1b: Flutter unit tests (fast)

Use for Dart logic and FFI service integration. Uses the **algorithm-testing word list** (1,273 words) for speed.

```bash
cd wrdlHelper
flutter test
```

1. **Red** — Add a test in `test/` that fails.
2. **Green** — Implement until `flutter test` passes.

### Tier 2: Integration tests (requires device/simulator)

Use for end-to-end flows, UI interactions, and real FFI performance.

```bash
cd wrdlHelper
flutter test integration_test/
```

1. **Red** — Add a spec in `integration_test/` that fails.
2. **Green** — Implement until the integration test passes.

### Order of tiers

- **Pure Rust logic:** Tier 1a first, then Tier 1b if FFI-exposed.
- **Flutter + FFI:** Tier 1b first, then Tier 2 for full device testing.
- **UI-only:** Tier 1b (widget tests), then Tier 2 if needed.

### Exceptions

- Docs-only, config-only, or comment-only changes.
- Trivial one-line fixes with no behavior change (still run the gate).
- Pure refactors preserving behavior: keep tests green.

Never leave failing tests on `main`.

---

## Evidence loop (device/FFI logs → cargo/flutter test → CI)

1. **Emit** — Named events on solver decisions, FFI errors, and UI commits. Fields you would assert (counts, enums, durations). No per-guess spam in the hot solver path.
2. **Verify** — Device/integration checklist uses those lines. Missing expected line = fail.
3. **Harvest** — After a find: if the decision is Rust-pure, add `cargo test` first; if it is Dart/FFI wiring, add `flutter test`. Name the test after the scenario. Keep the log as the Tier 2 item.
4. **CI** — Merge-ready runs those tests every time. Do not leave “we’ll catch it on the next device run” as the only net.

---

## Merge-ready gate

Run before every push to `main`:

```bash
cd wrdlHelper
flutter test && cd rust && cargo test && cd ..
```

Same checks should run in CI if you use GitHub Actions.

---

## Test categories in this project

| Category | Location | Purpose |
|----------|----------|---------|
| FFI service tests | `test/ffi_service_*_test.dart` | Validate Rust function accessibility |
| Performance tests | `test/performance/` | Benchmark FFI call overhead |
| Widget tests | `test/widgets/` | UI component behavior |
| Algorithm tests | `test/*_algorithm_test.dart` | Solver correctness |
| Integration tests | `integration_test/` | End-to-end on device |
| Rust unit tests | `rust/src/api/*.rs` | Pure Rust logic |

---

## Algorithm-testing word list

Tests use a curated 1,273-word list (not the full 17,169-word production list) for speed. This list maintains algorithm coverage while being 13x faster.

See [docs/TESTING_STRATEGY.md](../../docs/TESTING_STRATEGY.md) for details.
