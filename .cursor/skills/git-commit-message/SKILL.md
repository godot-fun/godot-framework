---
name: git-commit-message
description: Generate single-line Conventional Commits messages by analyzing git diffs and repository history. Use when the user asks for commit messages, help writing commits, reviewing staged changes, or preparing a git commit.
---

# Git Commit Message

## Quick Start

When the user needs a commit message:

1. Inspect changes: `git status`, `git diff`, `git diff --staged`
2. Read recent style: `git log --oneline -15`
3. Draft a single-line Conventional Commits message matching repo conventions
4. Return the message only — do not commit unless explicitly asked

Run status, diff, and log in parallel when possible.

## Message Format

Single line only — **no body**:

```
<type>[<scope>]: <subject>
```

| Part | Rules |
|------|-------|
| **type** | Required. One of: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `ci`, `build`, `style`, `revert` |
| **scope** | Optional. Module or area in square brackets (e.g. `[auth]`, `[api]`, `[ui]`). Omit brackets entirely if unclear |
| **subject** | Imperative mood, lowercase, no trailing period, ≤72 chars. Must stand alone — pack intent into this line |

**Never** add a blank line or body paragraph after the subject.

### Type Selection

| Type | When |
|------|------|
| `feat` | New user-facing capability |
| `fix` | Bug fix |
| `refactor` | Code change without behavior change |
| `docs` | Documentation only |
| `test` | Tests only |
| `chore` | Maintenance, deps, tooling |
| `perf` | Performance improvement |
| `ci` | CI/CD config |
| `build` | Build system or external deps |
| `style` | Formatting, whitespace (no logic change) |
| `revert` | Revert a prior commit |

### Scope Guidelines

- Use existing scopes from recent commits when present
- Prefer short, stable names: `auth`, `db`, `config`, `deps`
- Drop scope rather than guess incorrectly

## Workflow

```
Task Progress:
- [ ] Run git status + diff (+ staged diff if relevant)
- [ ] Read recent git log for style alignment
- [ ] Identify primary change type and scope
- [ ] Draft single-line subject (imperative, self-contained)
- [ ] Check for secrets or files that should not be committed
- [ ] Present message to user
```

### Split vs Single Commit

- **One logical change** → one commit
- **Unrelated changes** (feat + fix in different areas) → suggest splitting
- **Large refactor + feature** → suggest separate commits

## Safety

- Never include secrets (.env, credentials, tokens) in the commit
- Warn if staged files look sensitive
- Do not run `git commit` unless the user explicitly requests it

## Output

Present exactly one line in a copy-paste block:

```
feat[auth]: add jwt token refresh endpoint
```

```
fix[ui]: prevent double submit on checkout form
```

## Additional Resources

- More examples: [examples.md](examples.md)
