# Project status

**Human-readable current state.** Keep in sync with [AGENT_HANDOFF.md](../AGENT_HANDOFF.md) → *Current state* when milestones ship.

**Last updated:** 2026-06-10

---

## Summary

**Rust_Julia_FFI_Flutter_Template** — production-ready Flutter + Rust (+ Julia hooks) FFI template. Reference app: **wrdlHelper** (Wordle solver demo). Fragile build/FFI paths — see [SETUP_GUIDE.md](SETUP_GUIDE.md).

---

## Active branch

| Branch | Role |
|--------|------|
| **`main`** | Integration branch — template baseline |

---

## Completed (template baseline)

- Working Flutter-Rust FFI via flutter_rust_bridge + Cargokit
- wrdlHelper reference implementation (Wordle UI + Rust solver)
- Architecture, setup, and testing docs under `docs/`
- **Contributor onboarding norm:** CONTRIBUTING.md, PROJECT_STATUS, GitHub PR/issue templates

---

## Next up (maintainers)

- Optional: neutralize Wordle-specific demo per downstream needs (see MeowdokuHelper `docs/TEMPLATE_WORDLE_CLEANUP_PLAN.md` for a reference plan)
- Manual sync of `.cursor/` from AgenticTemplate when shared skills/rules change

---

## Reading order for contributors

See [CONTRIBUTING.md](../CONTRIBUTING.md).
