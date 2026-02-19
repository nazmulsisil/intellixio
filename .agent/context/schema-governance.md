# Schema Governance (No MCPs)

## Source of truth
Schema snapshots in this repo are the authoritative reference for:
- table/column names
- constraints and relationships
- data types and enums
- extension usage (e.g., PostGIS, pg_trgm)

When schema snapshots disagree with application code, assume:
1) the schema changed and snapshots are stale, or
2) the code is stale/mistaken.

Resolve the mismatch by updating the snapshots and/or code in the same change.

## Where schema snapshots live
Schema snapshots live with the app that owns/uses them:

- `apps/*/.agent/schemas/*.sql` for Postgres schema snapshots
- `apps/*/.agent/schemas/*` for other authoritative contracts (e.g., GeoJSON types)

When working inside an app folder, treat that app’s `.agent/schemas/` as the primary source of truth.
If a change impacts multiple apps, update each affected app’s schema snapshots in the same change.

## Update rules
- Any migration that changes schema MUST be accompanied by a snapshot update.
- Snapshots should be schema-only (no data) and kept deterministic.
- If multiple products share a database, keep a snapshot per logical schema/product.

## What not to do
- Do not “guess” columns or constraints from memory.
- Do not introduce new DB dependencies or external tools (no MCP usage).
- Do not write migration SQL without checking the current snapshot first.
