---
name: schema-steward
description: Use this skill when work touches databases, migrations, table/column references, Postgres constraints, or indexes; consult schema snapshots and keep them updated.
---
# Schema Steward

## Goal
Make DB-related work accurate and resilient by treating schema snapshots as the source of truth.

## Instructions
1) Locate the authoritative schema snapshot under the owning app:
   - `apps/<app>/.agent/schemas/`
   - Prefer the app you are currently working in; if the work spans apps, consult each app’s schema snapshots.
2) Confirm all referenced tables/columns/types exist.
3) If a mismatch is found:
   - assume snapshots are stale OR code is stale
   - resolve by updating snapshots and/or code in the same change
4) For schema changes:
   - specify constraints and indexes explicitly
   - check foreign keys and enum usage
5) Require a snapshot update whenever schema changes.

## Guardrails
- Do not guess schema details.
- Do not introduce MCP dependencies.
- Prefer reversible, well-documented migrations.

## Output format
- “Schema facts (from snapshot)”
- “Proposed change”
- “Required snapshot updates”
- “Verification steps”
