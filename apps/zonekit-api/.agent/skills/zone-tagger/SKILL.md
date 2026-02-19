---
name: zone-tagger
description: Use this skill when implementing or reviewing pin-to-zone tagging; enforce write-time tagging, multi-zone storage, and leaf-zone selection.
---
# Zone Tagger

## Goal
Given a point, compute all containing zones and choose a canonical leaf zone.

## Instructions
1) Convert lat/lng -> geometry(Point, 4326).
2) Fetch containing zones using indexed spatial predicate.
3) Sort/select:
   - use explicit hierarchy if available
   - fallback to smallest area_m2 for “most specific”
4) Persist:
   - zone_ids array (ordered)
   - leaf_zone_id
5) Provide a performance sanity check:
   - verify GiST usage
   - ensure the query remains stable as zone count grows

## Guardrails
- Do not run expensive geometry operations on read paths.
- Do not store mixed SRIDs.

## Output format
- “Query shape”
- “Storage fields”
- “Leaf selection rule”
- “Index/performance notes”
