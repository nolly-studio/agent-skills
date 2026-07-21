# Agent Skills

A collection of skills for AI coding agents. Skills are packaged instructions that extend agent capabilities.

Skills follow the [Agent Skills format](https://github.com/vercel-labs/skills) and are installable with the [`skills` CLI](https://skills.sh).

## Available Skills

### bootstrap-agents-md

Bootstrap a repository's AI coding agent operating system: a root `AGENTS.md` + `CLAUDE.md` entrypoint, deeper docs under `docs/agents/` (architecture, code style, lessons learned), durable plans under `docs/plans/`, a `docs/release.md`, and portable `plan-mode` / `code-review` skills — all rewritten from evidence gathered in the target repo, never copied blindly.

**Use when:**

- Setting up agent docs for a new project
- Porting a proven agent operating system to an existing codebase
- Consolidating scattered `AGENTS.md` / `CLAUDE.md` / Cursor rules into one source of truth
- Establishing living-docs discipline (lessons learned, plans, script-first commands)

**What it creates in the target repo:**

```
AGENTS.md                          # root entrypoint (living document)
CLAUDE.md                          # symlink -> AGENTS.md
docs/
  agents/
    architecture.md                # real system map, written from evidence
    code-style.md                  # the repo's actual conventions
    lessons-learned.md             # seeded, append-only knowledge base
  plans/
    README.md                      # how durable plans work
  release.md                       # how the project ships
.agents/
  skills/
    plan-mode/SKILL.md             # system-aware planning doctrine
    code-review/SKILL.md           # context-first review doctrine
```

**Key principles:**

1. Evidence first — every doc claim traces to something observed in the target repo
2. Port the system and doctrine, rewrite the content
3. Living docs — agents append lessons when they learn something non-obvious
4. Scripts over raw tools — commands come from `package.json`, not generic binaries
5. Plan before large changes, verify with project CI
6. Accurate short docs over impressive long docs

## Installation

### skills CLI (recommended — all supported agents)

```bash
npx skills add nolly-studio/agent-skills
```

Or install a specific skill without the interactive prompts:

```bash
npx skills add nolly-studio/agent-skills --skill bootstrap-agents-md -y
```

### Claude Code (manual)

```bash
cp -r skills/bootstrap-agents-md ~/.claude/skills/
```

### claude.ai

Add the skill to project knowledge or paste `SKILL.md` contents into the conversation.

## Usage

Skills are automatically available once installed. The agent uses them when relevant tasks are detected.

**Examples:**

```
Bootstrap the agent system for this repo
```

```
Set up AGENTS.md and agent docs following our standard structure
```

```
Port our agent operating system to this project
```

## Skill Structure

```
skills/
  bootstrap-agents-md/
    SKILL.md                             # instructions for the agent
    references/
      agents-md-template.md              # AGENTS.md skeleton
      architecture-template.md           # docs/agents/architecture.md
      code-style-template.md             # docs/agents/code-style.md
      lessons-learned-template.md        # docs/agents/lessons-learned.md
      plans-readme-template.md           # docs/plans/README.md
      release-template.md                # docs/release.md
      skill-plan-mode.md                 # portable plan-mode skill
      skill-code-review.md               # portable code-review skill
```

The agent reads `SKILL.md` for the process (evidence gathering, deliverables, verification pass) and pulls each template from `references/` at the step that uses it.

## License

MIT
