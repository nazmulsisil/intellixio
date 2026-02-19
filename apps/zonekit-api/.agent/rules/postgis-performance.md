---
trigger: always_on
---

# PostGIS Performance Rules

## Indexing
- Zones boundary column must have a GiST index.
- If you do fuzzy lookup by zone name, use pg_trgm indexes for normalized text.

## Query patterns
- Prefer:
  - bounding box prefiltering (implicit in many PostGIS ops) plus indexed spatial predicate
- Avoid:
  - repeated ST_Transform on hot paths
  - ST_Distance sorting across large candidate sets without prefilters

## Write-time tagging
- Match pins at write/update time and persist results.
- Reads should primarily join on stored ids, not compute geometry containment repeatedly.

## Diagnostics
- Use EXPLAIN/ANALYZE to confirm index usage when performance is questioned.
- If an index is not used, simplify the predicate and confirm SRID/types match.
