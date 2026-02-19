# Intellixio Monorepo Overview

## What this repo is
Intellixio ships multiple products from a single Turborepo monorepo. The repo contains both frontend and backend applications, plus shared packages.

Core products in this monorepo include:
- Zendowhisper: conversational AI + workspace messaging orchestration.
- Zendolead: seller onboarding, product publishing, lead generation, matching, and outreach.
- ZoneKit: polygon-based area/zone matching and location resolution services used by Zendolead/Zendowhisper and other apps.

## How the repo is typically organized
This monorepo follows common Turborepo conventions:
- `apps/` contains deployable applications (APIs, web apps, workers).
- `packages/` contains shared libraries (types, UI, configs, utilities).

If the actual structure differs, treat the directory containing `turbo.json` as the workspace root and infer app/package boundaries from:
- `turbo.json` pipelines
- package manifests under `apps/**/package.json` and `packages/**/package.json`
- workspace config (e.g., `pnpm-workspace.yaml`)

## Safety rules for cross-app work
- Prefer changes scoped to a single app/package unless the request explicitly requires cross-cutting changes.
- Shared packages are considered public contracts. Any change must be compatible with all downstream dependents.
- If you must touch multiple apps/packages:
  - Explain the dependency chain.
  - Keep changes minimal and versioned (if your tooling/versioning requires it).
  - Validate at least the affected tasks for each dependent app (build/typecheck/tests).

## Development conventions (high level)
- Package manager: pnpm.
- Task runner: Turbo.
- Prefer running tasks via Turbo with filters to avoid unnecessary work.
- Treat database schema snapshots as authoritative documentation for DB work.
