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
- Even though workspaces may be opened at the app folder level, **you MUST run all CLI, `pnpm`, and `turbo` commands from the monorepo root**.
- If you are in a subdirectory, the monorepo root is located at `../../` (or higher) relative to the app directory.
- When using your terminal tool, always set the working directory (`Cwd`) to the monorepo root.
- Prefer `pnpm <script>` wrappers defined at repo root.
- Rely on turborepo filtering to scope commands to a specific app, e.g.: `pnpm turbo run <task> --filter=<target>`.
- NEVER run `pnpm install` or `turbo run` from inside the app directory directly.

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
