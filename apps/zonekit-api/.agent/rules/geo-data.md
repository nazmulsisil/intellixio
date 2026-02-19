---
trigger: always_on
---

# Geo Data Conventions (GeoJSON + PostGIS)

## GeoJSON contract
- Input features are GeoJSON with geometry.type = "Polygon" or "MultiPolygon".
- Coordinate order is [longitude, latitude].
- Store geometries in DB as MULTIPOLYGON with SRID 4326.

## Normalization rules
- Always convert Polygon -> MultiPolygon on ingestion for uniformity.
- Ensure rings are closed and valid; repair only if you can do so deterministically.
- Keep original external identifiers (shapeID/shapeISO/shapeType/shapeGroup) as immutable keys when available.

## Output rules
- For point-in-polygon matching, use predicates that include boundary points when desired.
- Store both:
  - zone_ids[] (all containing zones)
  - leaf_zone_id (most specific winner) when the product needs a single canonical area
