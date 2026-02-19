# Turborepo Playbook (Intellixio)

## Key principles
- Run tasks through Turbo for correct dependency ordering and caching.
- Keep execution scoped using `--filter` so work stays within the intended app/package.
- Prefer “read/plan/verify” loops:
  1) inspect package boundaries
  2) run scoped checks
  3) apply minimal edits
  4) re-run scoped checks

## Common commands (from repo root)
- Install: `pnpm install`
- Dev: `pnpm dev`
- Build: `pnpm build`
- Lint: `pnpm lint`
- Typecheck: `pnpm check-types`
- Format: `pnpm format`

These are wrappers around Turbo tasks; confirm by checking `package.json` and `turbo.json`.

## Dependencies are pinned
All dependency installs must use exact versions (use `--save-exact` with pnpm).

## Running a task for one app/package
Use Turbo filters (examples):
- By package name: `pnpm turbo run build --filter=<package-name>`
- By directory: `pnpm turbo run lint --filter=./apps/some-app`
- Include dependencies: `pnpm turbo run build --filter=<package-name>...`
- Only dependents: `pnpm turbo run build --filter=...<package-name>`

## From inside an app folder
If your terminal starts in `apps/<app-name>`, run Turbo from repo root:
- `cd ../..`
- then run the Turbo command you need.

## When to avoid broad runs
Do not run `pnpm turbo run <task>` across the entire monorepo unless:
- the change is in shared infra/config and could affect many packages, or
- CI validation requires a full run, or
- the user explicitly requests a full sweep.

## Coupling guardrails
- Do not add new imports from other apps.
- Shared code belongs in `packages/`.
- If an app needs another app’s logic, extract a shared package instead.
