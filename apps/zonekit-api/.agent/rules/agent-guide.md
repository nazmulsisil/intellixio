---
trigger: always_on
---

# Agent Guide (ZoneKit API)

## Scope
These rules apply only within the ZoneKit API app workspace.

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
