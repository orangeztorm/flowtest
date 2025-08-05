# **FlowTest Monorepo — Master PLAN.md (v0.3)**

> **Purpose**   Serve as the *single source‑of‑truth* for every sub‑project, sprint, and convention inside the `flowtest` mono‑repo. Each package/service gets its own **inner PLAN.md** (scaffolded below) but this root document explains *how they fit together.*

---

## 🗂 Repo Layout & Ownership

```
flowtest/               # <root mono‑repo>
├─ packages/            # 🍭 everything published to pub.dev / VS Code marketplace
│  ├─ flowtest_sdk/     # ▸ Dart + Flutter library  (Owner: SDK Team) ✅ COMPLETE
│  ├─ flowtest_cli/     # ▸ CLI runner & recorder  (Owner: CLI Team) 🔄 NEXT
│  └─ flowtest_vscode/  # ▸ VS Code extension     (Owner: DX Team) ⏳ PLANNED
├─ services/            # 🌩️ backend micro‑services
│  └─ llm_service/      # ▸ FastAPI prompt→flow   (Owner: AI Team) ⏳ PLANNED
├─ examples/            # 🍱 sample Flutter apps wired to the SDK
│  └─ sample_app/       # ▸ Demo app with SDK integration ✅ READY
├─ docs/                # 📚 Docusaurus static site (published to GitHub Pages)
├─ scripts/             # 🛠️ Dev helpers (emulator boot, release, etc.)
└─ .github/workflows/   # ⚙️ CI/CD pipelines (shareable across packages)
```

*Every folder under `packages/` or `services/` **must** contain its own `README.md`, `CHANGELOG.md`, **and** `PLAN.md`.*

---

## 🔑 Global Engineering Principles

| Principle                 | Rationale & Rule of Thumb                                                                                  |
| ------------------------- | ---------------------------------------------------------------------------------------------------------- |
| **Modular autonomy**      | Each sub‑package must build & test in isolation via `dart pub get && dart test`.                           |
| **Convention > config**   | Follow defaults (Melos workspace, Flutter lint preset) unless a **written exception** exists.              |
| **Single‑direction deps** | SDK ← CLI ← IDE; never import CLI code back into SDK.                                                      |
| **Fast feedback loops**   | `flutter test` must finish < 45 s locally; CI < 3 min (debug build).                                       |
| **Versioned contracts**   | JSON Flow schema carries `"schema": <N>`; breaking change bumps major of **all** packages.                 |
| **Red line on flakiness** | Integration test flake rate ≤ 2 %. Jobs auto‑retry once; > 3 failures/week triggers *SEV‑3* investigation. |

---

## 📅 10‑Week Macro Roadmap

| Sprint (2 wk) | Focus                                                             | Exit Criteria ✔︎                                                                     | Status |
| ------------- | ----------------------------------------------------------------- | ------------------------------------------------------------------------------------ | ------ |
| **S1**        | Foundation freeze (schema, SDK 0.9.0‑dev, green CI)               | ✅ All unit + integration tests pass in CI<br>✅ `flowtest_sdk` on pub.dev (0.9.0‑dev) | ✅ **COMPLETE** |
| **S2**        | CLI Alpha (`flowtest record/run/list`, local README)              | ✅ CLI commands implemented<br>✅ Local documentation<br>✅ SDK integration | 🔄 **IN PROGRESS** |
| **S3**        | LLM Service MVP (`/v1/flow/generate`, CLI `prompt` cmd)           | ✅ FastAPI service deployed<br>✅ Prompt-to-flow generation<br>✅ CLI integration | ⏳ **PLANNED** |
| **S4**        | VS Code Ext Alpha (Flow Explorer + Run button)                    | ✅ Extension published to marketplace<br>✅ Flow explorer UI<br>✅ Run button integration | ⏳ **PLANNED** |
| **S5**        | Visual Editor + Prompt bar (React webview)                        | ✅ Web-based flow editor<br>✅ Prompt bar integration<br>✅ Real-time preview | ⏳ **PLANNED** |
| **S6**        | CI Reference Pipeline (sample app, headless emu, artifacts)       | ✅ CI/CD pipeline documented<br>✅ Headless emulator setup<br>✅ Artifact collection | ⏳ **PLANNED** |
| **S7**        | Performance Sprint (fast‑mode, AVD snapshot, sharding)            | ✅ Test execution optimization<br>✅ AVD snapshot management<br>✅ Parallel test sharding | ⏳ **PLANNED** |
| **S8**        | Public Beta hardening (docs site, security audit, Windows runner) | ✅ Documentation site live<br>✅ Security audit completed<br>✅ Windows compatibility | ⏳ **PLANNED** |
| **S9**        | JetBrains plugin prototype + Offline LLM investigation            | ✅ JetBrains plugin alpha<br>✅ Offline LLM feasibility study<br>✅ Performance benchmarks | ⏳ **PLANNED** |
| **S10**       | **v1.0 GA** launch (blog, CFP, marketing assets)                  | ✅ Public launch<br>✅ Marketing materials<br>✅ Community engagement | ⏳ **PLANNED** |

> **NOTE** – Sprints may overlap for different teams; the column above shows the *primary* theme.

---

## 🏗️ Per‑Package PLAN.md Template

Each inner `PLAN.md` should be created by copying this template and filling the blanks.

```markdown
# <package_name> PLAN.md  (v0.1‑draft)

## 1 · Mission
<One‑sentence description of what this package does and *why* it exists>

## 2 · Public API (MVP)
- [ ] List exported classes / commands
- [ ] Example snippet

## 3 · Milestones
| Iteration | Features | ETA |
|-----------|----------|-----|
| `0.9.0‑dev` | <bullets> | |
| `0.9.1` | | |
| `1.0.0` | *GA* | |

## 4 · Tech Stack Decisions
| Area | Choice | Reason |
|------|--------|--------|
| Build | | |
| Testing | | |
| Linting | | |

## 5 · Open Risks / Questions
- …
```

---

## 🎯 Immediate Next Actions (updated)

| Owner            | Task                                                             | Folder / File                  | ETA      | Status |
| ---------------- | ---------------------------------------------------------------- | ------------------------------ | -------- | ------ |
| **SDK Team**     | ✅ SDK 1.0.0 complete - production ready                        | `packages/flowtest_sdk/`       | ✅ DONE  | ✅ **COMPLETE** |
| **CLI Team**     | 🔄 Create `packages/flowtest_cli` & implement core commands      | `packages/flowtest_cli/`       | +3 days  | 🔄 **IN PROGRESS** |
| **Docs Team**    | 🔄 Create `docs/flow_format.md` + JSON schema                    | `docs/`                        | +2 days  | 🔄 **IN PROGRESS** |
| **CI Team**      | 🔄 Set up monorepo CI/CD with Melos                              | `.github/workflows/`           | +2 days  | 🔄 **IN PROGRESS** |
| **AI Team**      | ⏳ Draft FastAPI prompt template & validation                    | `services/llm_service/PLAN.md` | +1 week  | ⏳ **PLANNED** |

---

### How to start a new Inner Plan

1. Navigate to the target folder (`packages/flowtest_cli`).
2. Create `PLAN.md` based on the template above.
3. Commit with `docs(cli): add PLAN.md skeleton`.
4. Update the *Sub‑Project Links* table below.

---

## 🔗 Sub‑Project Links (updated)

| Package / Service             | README | PLAN (inner) | Status |
| ----------------------------- | ------ | ------------ | ------ |
| **SDK** `flowtest_sdk`        | ✅ [README](packages/flowtest_sdk/README.md) | ✅ [PLAN](packages/flowtest_sdk/plan.md) | ✅ **COMPLETE** |
| **CLI** `flowtest_cli`        | ⏳ TBD | ⏳ TBD | 🔄 **NEXT** |
| **VS Code** `flowtest_vscode` | ⏳ TBD | ⏳ TBD | ⏳ **PLANNED** |
| **LLM Service** `llm_service` | ⏳ TBD | ⏳ TBD | ⏳ **PLANNED** |

---

## 🎉 **Sprint S1 Achievement: SDK Foundation Complete**

### ✅ **What Was Accomplished**
- **Complete SDK implementation** with all 7 core steps
- **Production-ready quality** with comprehensive error handling
- **Cross-platform support** (iOS, Android, Web, Desktop)
- **Professional logging** and storage systems
- **Comprehensive testing** and documentation
- **Visual recording** and automated playback
- **Unified widget targeting** with intelligent resolution

### 🚀 **Ready for Next Phase**
The SDK foundation is solid and ready to support:
- CLI development (Sprint S2)
- VS Code extension (Sprint S4)
- LLM service integration (Sprint S3)
- CI/CD pipeline setup (Sprint S6)

---

## 🧭 Navigation & Updates

* **This file** evolves only when cross‑project direction changes (e.g. new sprint, schema bump).
* Inner `PLAN.md` files track *implementation details* and may update daily.
* Use `scripts/bump_version.sh` to tag releases consistently across all packages.

> **Remember:** if a decision affects *more than one* package, update **this** master plan.
