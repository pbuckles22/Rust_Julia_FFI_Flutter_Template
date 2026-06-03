# DEV_GUIDE — Rust_Julia_FFI_Flutter_Template

## Tech stack

- **Frontend:** Flutter 3.9.2+ (iOS, macOS, Android)
- **Backend:** Rust 1.70+ with flutter_rust_bridge 2.11.1
- **Scientific computing:** Julia 1.9+ (optional integration)
- **FFI bridge:** flutter_rust_bridge for seamless Dart ↔ Rust calls
- **Build system:** Cargokit (rust_builder/) for cross-platform Rust compilation

## Architecture

```
Rust_Julia_FFI_Flutter_Template/
├── wrdlHelper/                  # Main Flutter project
│   ├── lib/                     # Dart source code
│   │   ├── main.dart            # App entry point
│   │   ├── services/            # FFI service layer
│   │   ├── controllers/         # State management
│   │   ├── screens/             # UI screens
│   │   ├── widgets/             # Reusable widgets
│   │   └── src/rust/            # Generated FFI bindings (DO NOT EDIT)
│   ├── rust/                    # Rust backend
│   │   ├── src/
│   │   │   ├── lib.rs           # Library entry point
│   │   │   └── api/             # FFI-exposed functions
│   │   └── Cargo.toml           # Rust dependencies
│   ├── rust_builder/            # Cargokit FFI plugin
│   ├── ios/                     # iOS project (Xcode, Podfile)
│   ├── android/                 # Android project
│   ├── test/                    # Flutter tests
│   ├── integration_test/        # Integration tests
│   ├── assets/word_lists/       # Game data
│   └── flutter_rust_bridge.yaml # FFI config
├── docs/                        # Extensive documentation
│   ├── SETUP_GUIDE.md           # Step-by-step setup
│   ├── TESTING_STRATEGY.md      # Test approach
│   └── COMPREHENSIVE_ARCHITECTURE.md
└── scripts/                     # Build/rename scripts
```

## FFI workflow

### Adding a new Rust function

1. **Define in Rust** (`wrdlHelper/rust/src/api/simple.rs` or new module):
   ```rust
   #[flutter_rust_bridge::frb(sync)]
   pub fn my_new_function(input: String) -> String {
       format!("Processed: {}", input)
   }
   ```

2. **Regenerate bindings:**
   ```bash
   cd wrdlHelper
   flutter_rust_bridge_codegen generate
   ```

3. **Use in Dart** (bindings appear in `lib/src/rust/api/`):
   ```dart
   import 'package:wrdl_helper/src/rust/api/simple.dart';
   final result = myNewFunction(input: "test");
   ```

4. **Test both sides:**
   - Rust: Add test in `rust/src/api/simple.rs` `#[cfg(test)]` module
   - Flutter: Add test in `test/`

### Attribute reference

| Attribute | Use case |
|-----------|----------|
| `#[flutter_rust_bridge::frb(sync)]` | Synchronous call, returns immediately |
| `#[flutter_rust_bridge::frb(init)]` | Initialization function |
| `pub async fn` | Async function (runs on Rust thread pool) |

## High-risk areas

| Area | Risk | Mitigation |
|------|------|------------|
| `ios/Podfile` | Breaks iOS build | Don't modify unless fixing CocoaPods issues |
| `ios/Runner.xcodeproj` | Breaks iOS build | Use Xcode for project changes |
| `rust/Cargo.toml` | Breaks FFI | Test `cargo build` after changes |
| `flutter_rust_bridge.yaml` | Regenerates all bindings | Backup `lib/src/rust/` first |
| `lib/src/rust/` | Generated code | Never edit manually |

## Conventions

- **Pure functions:** Prefer pure functions in Rust for testability.
- **Error handling:** Use `Result<T, E>` in Rust; catch in Dart.
- **Memory:** Rust owns data; pass copies across FFI boundary.
- **Testing:** Test Rust logic with `cargo test`, Flutter integration with `flutter test`.
- **Documentation:** Update docs/ when architecture changes.

## Commands reference

```bash
# Flutter
flutter pub get           # Install dependencies
flutter run               # Run app
flutter test              # Unit tests
flutter build ios         # iOS release build

# Rust
cd wrdlHelper/rust
cargo build               # Debug build
cargo build --release     # Release build
cargo test                # Run tests
cargo clippy              # Linting

# FFI regeneration
cd wrdlHelper
flutter_rust_bridge_codegen generate
```
