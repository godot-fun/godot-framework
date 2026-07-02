# Commit Message Examples

All messages are **single line only** — no body.

## feat

**Input:** Added user login with email/password and session cookies

```
feat[auth]: add email/password login with http-only cookies
```

## fix

**Input:** Fixed dates showing wrong timezone in reports

```
fix[reports]: correct timezone conversion for date display
```

## refactor

**Input:** Extracted duplicate validation logic into shared helper

```
refactor[validation]: extract shared field validators
```

## docs

**Input:** Updated README with setup instructions

```
docs: add local development setup guide
```

## test

**Input:** Added unit tests for payment retry logic

```
test[payments]: cover retry backoff edge cases
```

## chore

**Input:** Bumped lodash from 4.17.20 to 4.17.21

```
chore[deps]: bump lodash to 4.17.21
```

## perf

**Input:** Added index on user_id column, queries 10x faster

```
perf[db]: add index on orders.user_id
```

## ci

**Input:** Added GitHub Actions workflow for lint

```
ci: add lint workflow on pull requests
```

## revert

**Input:** Reverting commit abc1234 that broke prod deploy

```
revert: revert feat[deploy] blue-green rollout (abc1234)
```

## Multi-file / ambiguous scope

**Input:** Changed auth middleware and updated related tests

```
feat[auth]: enforce token expiry on protected routes
```

Prefer the **primary behavioral change** as type/scope; test updates are implied.

## Bad → Good

| Bad | Good | Why |
|-----|------|-----|
| `Fixed bug` | `fix[api]: handle null response from upstream` | Specific, typed |
| `Updated files` | `refactor[ui]: simplify modal state management` | Describes intent |
| `feat: Added new feature.` | `feat[search]: add fuzzy matching for queries` | No period, imperative, scoped |
| `feat(auth): add login` | `feat[auth]: add login` | Scope uses square brackets |
| Subject + body paragraph | `fix[auth]: use http-only cookies for session storage` | Single line only |
| `WIP` | (suggest splitting or completing work) | Not a valid commit message |
