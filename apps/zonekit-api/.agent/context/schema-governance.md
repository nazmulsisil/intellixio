# ZoneKit Schema Governance

## Authoritative files
- `.agent/schemas/zonekit.postgis.sql`
- `.agent/schemas/geojson.ts`

## Update rule
If application code changes:
- table names
- columns
- indexes
- constraints
- enum usage
then you must update `.agent/schemas/zonekit.postgis.sql` in the same change.

## No MCPs
All DB reasoning must be based on these snapshots and in-repo code.
Do not assume external database introspection tools are available.
