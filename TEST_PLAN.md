# Test plan (TEST_PLAN.md)

Three-tier testing for Flutter-Rust FFI. See [docs/TESTING_STRATEGY.md](docs/TESTING_STRATEGY.md) for the algorithm-testing word list approach.

**Integration chain:** A passing `cargo test` of one function is not enough. Merge-ready (`flutter test` and `cargo test`) must include a test that crosses the FFI boundary when the change crosses it, and a test that the shipped behaviors still run together. Device Tier 2 does not replace that. Rule: [.cursor/rules/integration-chain.mdc](.cursor/rules/integration-chain.mdc).

---

## Tier 1a: Rust unit tests (fastest)

Pure Rust logic (algorithms, data processing, word filtering).

```bash
cd wrdlHelper/rust
cargo test
```

---

## Tier 1b: Flutter unit tests (fast)

Dart logic and FFI service integration. Uses the **algorithm-testing word list** (1,273 words) for speed.

```bash
cd wrdlHelper
flutter test
```

---

## Tier 2: Integration tests (requires device/simulator)

End-to-end flows, UI interactions, and real FFI performance.

```bash
cd wrdlHelper
flutter test integration_test/
```

---

## Merge-ready gate

Run before every push to `main`:

```bash
cd wrdlHelper
flutter test && cd rust && cargo test && cd ..
```

Same checks should run in CI if you use GitHub Actions.

**Handoff:** Document the exact commands you use for coverage in AGENT_HANDOFF.md so agents can run them consistently.

**Evidence:** Named Rust/Dart events on FFI and solver decisions. Harvest device finds into `cargo test` first when the logic is Rust-pure (TEST_TDD → *Evidence loop*).
