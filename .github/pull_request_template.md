## Summary

<!-- What changed and why. Link issue or PROJECT_STATUS item. -->

## Checklist

- [ ] Matches [docs/PROJECT_STATUS.md](../docs/PROJECT_STATUS.md) or agreed issue
- [ ] Merge-ready gate green (`cd wrdlHelper && flutter test && cd rust && cargo test && cd ..`)
- [ ] Did **not** hand-edit `wrdlHelper/lib/src/rust/` or generated FRB files
- [ ] If `rust/src/api/` changed: ran `flutter_rust_bridge_codegen generate`
- [ ] If `ios/`, `rust_builder/`, or `Cargo.toml` changed: followed [docs/SETUP_GUIDE.md](../docs/SETUP_GUIDE.md)
- [ ] Updated **docs/PROJECT_STATUS.md** + **AGENT_HANDOFF** *Current state* if direction changed
- [ ] No secrets; contributor-facing decisions not only in gitignored handoff files
