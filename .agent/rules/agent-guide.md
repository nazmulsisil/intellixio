---
trigger: always_on
---

# Agent Guide (Repo-wide)

These rules apply to all work in the Intellixio monorepo.

## Default operating loop
1) Identify the target scope (single app/package unless explicitly cross-cutting).
2) Read relevant context docs in `.agent/context/`.
3) Inspect existing code and schema snapshots before proposing changes.
4) Make minimal, well-scoped edits.
5) Validate with scoped Turbo tasks.
6) Summarize what changed and why, including how to run verification.

## Turborepo + pnpm
- Prefer `pnpm <script>` wrappers defined at repo root.
- Use `pnpm turbo run <task> --filter=<target>` for scoped work.
- If you are in a subdirectory, `cd` to repo root before running Turbo.

## Safety and permissions
- If Antigravity is configured with Strict Mode, follow it. Prefer safety over speed.
- Prefer dry-runs and read-only inspection commands when exploring.
- Avoid destructive commands unless explicitly requested and understood.

## Change boundaries
- Avoid cross-app coupling:
  - do not import from other apps
  - do not reference internal files across app boundaries
- Shared logic belongs in `packages/`.

## Schemas
- Treat schema snapshots as authoritative.
- If a task touches DB tables/columns/indexes, consult `.agent/schemas/*` first.
- If you discover the snapshots are stale, update them as part of the same change.

## Dependency installation (exact versions)
When adding or updating dependencies, always pin exact versions.

- Add prod dep: `pnpm add --save-exact <pkg>`
- Add dev dep: `pnpm add -D --save-exact <pkg>`
- Update to latest exact: `pnpm up --latest --save-exact <pkg>`

Do not introduce `^` or `~` ranges in package.json dependencies.
