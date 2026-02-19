---
trigger: always_on
---

# Schema-First Rules (Repo-wide)

## Authoritative sources
- App-local schema snapshots: `apps/*/.agent/schemas/*.sql`
- App-local typed contracts (when present): `apps/*/.agent/schemas/*.{ts,json,yml,yaml}`

Rule: DB work must reference the schema snapshot(s) in the owning app(s), not root-level files.

## Required behavior for DB work
- Before writing code that references a table/column, confirm it exists in the snapshot.
- Before changing schema, confirm:
  - foreign keys and constraints
  - indexes used by common queries
  - enum usage and types

## Resilience to schema changes
- Never hardcode assumptions from prior runs.
- If a column/table is missing from the snapshot, assume the snapshot is stale and update it (or confirm the code should be changed).
- Keep schema snapshot updates mechanical and reviewable.