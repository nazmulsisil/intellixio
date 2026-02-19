---
description: 
---

---
description: Refresh schema snapshots after migrations or DB changes (no MCP usage).
---
# Update Schema Snapshots

Goal: Keep schema snapshots current and deterministic.

1) Identify which schema snapshot is affected:
   - Zendolead -> .agent/schemas/zendolead.sql
   - Zendowhisper -> .agent/schemas/zendowhisper-public.sql
   - Others -> add a new snapshot file under .agent/schemas/

2) Regenerate schema-only output using the project’s standard tooling.
   - Prefer schema-only exports (no data).
   - Keep ordering stable if possible.

3) Replace the snapshot file content.
4) Review the diff:
   - ensure only intended tables/columns/constraints changed
5) Commit snapshot updates with the code/migration change.
