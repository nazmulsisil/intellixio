---
trigger: always_on
---

# Agent Guide (ZoneKit API)

## Scope
These rules apply only within the ZoneKit API app workspace.

## Monorepo Command Execution
Even though this workspace focuses on the `zonekit-api` folder, **you MUST run all CLI, `pnpm`, and `turbo` commands from the monorepo root**.

1. The monorepo root is located at `../../` relative to this app directory.
2. When using your terminal tool, always set the working directory (`Cwd`) to the monorepo root.
3. Rely on turborepo filtering to scope commands to this app, e.g.:
   `pnpm turbo run build --filter=zonekit-api`
   `pnpm turbo run test --filter=zonekit-api`
4. NEVER run `pnpm install` or `turbo run` from inside the app directory directly.

## Operating rules
- Prefer write-time tagging and caches over repeated spatial queries on reads.
- Keep spatial SQL isolated behind repository/data-access layers.
- Validate GeoJSON ingestion carefully (types, SRID, ring closure, multipolygon handling).
- Avoid changing Zendolead/Zendowhisper app code from this workspace unless explicitly requested.

## Verification
Run the smallest set of checks that prove correctness:
- unit tests for resolver/tagging logic
- typecheck
- build/lint for this app
- migration/schema snapshot updates when DB shape changes

## Safety
- Prefer Strict Mode for any workflow that could run terminal commands with side effects.
- Never “guess” geometry type handling: confirm Polygon vs MultiPolygon support explicitly.

## Dependencies
Use exact dependency versions (`pnpm add --save-exact ...`). Do not add caret/tilde ranges.
