---
name: bootstrap-agents-md
description: Bootstrap a repository's AI coding agent operating system — AGENTS.md, CLAUDE.md, docs/agents (architecture, code-style, lessons-learned), docs/plans, docs/release.md, and portable plan-mode/code-review skills — all rewritten from evidence gathered in the target repo. Use when setting up agent docs for a new or existing project. Triggers on "bootstrap agent system", "set up AGENTS.md", "port agent docs", "create agent operating system", "agent onboarding docs".
license: MIT
metadata:
  version: "1.0.0"
---

# Bootstrap Agent System

You are setting up this repository's AI coding agent operating system, modeled on a proven pattern. Port the **system and doctrine**, then **rewrite all content for THIS repo based on evidence you gather here**. Never paste product-specific details from another codebase unless they verifiably apply to this repo.

## Goal

Give AI agents (Cursor, Claude Code, etc.) a single, living contract for how to work in this repo:

1. Root entrypoint docs (`AGENTS.md` + `CLAUDE.md`)
2. Deeper agent docs under `docs/agents/`
3. Durable plans under `docs/plans/`
4. Release notes under `docs/release.md`
5. Project skills under the repo's skills directory (e.g. `.agents/skills/`)
6. Explicit rules that agents must use project scripts, keep docs living, and record lessons

## Reference templates

This skill ships with templates in `references/`. Read each one when you reach the step that uses it:

| File | Used for |
|------|----------|
| `references/agents-md-template.md` | `AGENTS.md` skeleton |
| `references/architecture-template.md` | `docs/agents/architecture.md` |
| `references/code-style-template.md` | `docs/agents/code-style.md` |
| `references/lessons-learned-template.md` | `docs/agents/lessons-learned.md` |
| `references/plans-readme-template.md` | `docs/plans/README.md` |
| `references/release-template.md` | `docs/release.md` |
| `references/skill-plan-mode.md` | `.agents/skills/plan-mode/SKILL.md` (create verbatim) |
| `references/skill-code-review.md` | `.agents/skills/code-review/SKILL.md` (adapt commands) |

## Phase 0: Gather evidence (before writing anything)

Read these and take notes. Every claim in the docs you write must trace back to something you saw here:

- [ ] `package.json` (root + each workspace): scripts, `packageManager`, workspaces
- [ ] Lockfile(s): which package manager is actually in use
- [ ] CI config (`.github/workflows/`, `turbo.json`, `vercel.json`, etc.): what "green" means
- [ ] `tsconfig.json` / language configs: strictness flags agents must respect
- [ ] Lint/format config (eslint, biome, oxlint, prettier, ultracite, etc.) and how it is invoked
- [ ] Test setup: runner, file naming, colocation vs `__tests__/`
- [ ] Existing docs: `README.md`, `CONTRIBUTING.md`, any existing `AGENTS.md`/`CLAUDE.md`/`.cursor/rules` — inventory overlaps so you consolidate instead of contradicting
- [ ] Auth, database, migrations, deploy targets — only note what exists
- [ ] Directory layout: apps, packages, primary data/control flow

If the repo already has a partial `AGENTS.md` or Cursor rules, **merge** — preserve unique local rules, deduplicate, and keep one source of truth.

## Deliverables

```
AGENTS.md                          # root entrypoint (living document)
CLAUDE.md                          # symlink -> AGENTS.md
docs/
  agents/
    architecture.md                # real system map, written from evidence
    code-style.md                  # this repo's actual conventions
    lessons-learned.md             # seeded, append-only knowledge base
  plans/
    README.md                      # how durable plans work here
  release.md                       # how THIS project ships
.agents/
  skills/
    plan-mode/SKILL.md             # portable doctrine (references/skill-plan-mode.md)
    code-review/SKILL.md           # portable doctrine (references/skill-code-review.md)
    <stack skills as applicable>
```

## Process (in order)

1. **Phase 0** evidence gathering (checklist above)
2. Write `docs/agents/architecture.md` and `docs/agents/code-style.md` from evidence, using the corresponding templates as structure
3. Write `AGENTS.md` from `references/agents-md-template.md`; then symlink: `ln -sf AGENTS.md CLAUDE.md`. If symlinks are not viable (e.g. Windows contributors without dev-mode), create `CLAUDE.md` containing only: `See AGENTS.md — single source of truth.`
4. Add `docs/release.md`, `docs/plans/README.md`, and seed `docs/agents/lessons-learned.md` from their templates
5. Create `.agents/skills/plan-mode/SKILL.md` (verbatim from `references/skill-plan-mode.md`, stripping the template preamble) and `.agents/skills/code-review/SKILL.md` (from `references/skill-code-review.md`, adapting commands to this repo)
6. Add stack-specific skills only if the dependency is verified in `package.json` (AI SDK, workflow/durable-execution, React best practices, design-engineering, etc.). Do NOT port product-specific skills from other codebases.
7. Run the **verification pass** below
8. Report a short summary: files created, what was adapted vs skipped, conflicts found with existing docs, recommended next skills for this stack

## Operating doctrine (must be encoded in AGENTS.md + skills)

1. **Living docs** — when an agent is wrong or learns a non-obvious invariant, it appends to `docs/agents/lessons-learned.md`, ideally in the same change
2. **Scripts over raw tools** — discover commands from `AGENTS.md` / `package.json` before running generic `tsc` / `eslint` / etc.
3. **Plan before large changes** — plan-mode doctrine for multi-file/architectural work; durable plans in `docs/plans/`
4. **Separation of concerns** — extract colocated modules instead of growing god-files
5. **Verify with project CI** — after changes, run the repo's canonical check script
6. **Don't invent architecture** — document what exists; if unclear, explore and ask

## Verification pass (required before finishing)

- [ ] Every command listed in `AGENTS.md` exists in `package.json` scripts (or is a real workspace tool invocation) — run each read-only one to confirm
- [ ] Every relative link in `AGENTS.md` and `docs/agents/*` resolves to an existing file
- [ ] `CLAUDE.md` resolves to `AGENTS.md` content (`cat CLAUDE.md`)
- [ ] No section in any doc describes something you did not verify in this repo
- [ ] No contradictions with pre-existing docs (README, CONTRIBUTING, lint configs)
- [ ] `AGENTS.md` is scannable in under a minute (~100 lines)

## Constraints

- Do not copy another product's architecture (web/agent/sandbox splits, specific auth providers, database branching setups, etc.) unless verified in THIS repo
- Prefer accurate short docs over impressive long docs — an agent that trusts a wrong doc is worse than one with no doc
- No secrets or env values in docs; reference `.env.example` instead
- Match this repo's markdown tone and formatting
- If the target already has a partial `AGENTS.md`, merge carefully rather than overwriting unique local rules

## Done when

- An agent opening this repo can find commands, architecture, style, and lessons within one hop from `AGENTS.md`
- `CLAUDE.md` resolves to the same content
- Plan and review workflows exist as skills
- Every doc statement is evidence-backed and the verification pass is clean
