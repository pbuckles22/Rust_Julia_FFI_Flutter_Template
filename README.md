# Rust + Julia + Flutter FFI Template

Production-ready template for **Flutter + Rust** foreign function interfaces (Julia hooks optional). Includes **wrdlHelper** — a working Wordle solver reference app demonstrating the full FFI stack.

## New here?

**Start with [CONTRIBUTING.md](CONTRIBUTING.md)** — reading order, tracked vs gitignored docs, PR expectations.

**Current work:** [docs/PROJECT_STATUS.md](docs/PROJECT_STATUS.md)

**CRITICAL:** FFI bindings between Flutter, Rust, and iOS/macOS are **fragile**. Read [docs/SETUP_GUIDE.md](docs/SETUP_GUIDE.md) before changing `wrdlHelper/ios/`, `rust_builder/`, `flutter_rust_bridge.yaml`, or `rust/Cargo.toml`.

## Quick start

```bash
git clone https://github.com/pbuckles22/Rust_Julia_FFI_Flutter_Template.git
cd Rust_Julia_FFI_Flutter_Template/wrdlHelper
flutter pub get
flutter test
cd rust && cargo test && cd ..
# macOS: flutter run -d <device-id>
```

## What's included

| Area | Contents |
|------|----------|
| **wrdlHelper/** | Flutter app + Rust crate + generated FRB bindings |
| **docs/** | SETUP_GUIDE, architecture, testing strategy, PROJECT_STATUS |
| **.cursor/** | Agentic rules and skills (manual sync from AgenticTemplate) |
| **scripts/** | Utility scripts |

## Source of truth

[CONTRIBUTING.md](CONTRIBUTING.md), [docs/PROJECT_STATUS.md](docs/PROJECT_STATUS.md), [AGENT_HANDOFF.md](AGENT_HANDOFF.md), [docs/SETUP_GUIDE.md](docs/SETUP_GUIDE.md), [docs/TESTING_STRATEGY.md](docs/TESTING_STRATEGY.md).

## Related templates

- [AgenticTemplate](https://github.com/pbuckles22/AgenticTemplate) — stack-agnostic agentic layer
- [FlutterAgenticTemplate](https://github.com/pbuckles22/FlutterAgenticTemplate) — Flutter iOS-only scaffold without FFI
- [MeowdokuHelper](https://github.com/pbuckles22/MeowdokuHelper) — downstream product bolted from this template
