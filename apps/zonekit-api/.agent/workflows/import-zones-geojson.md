---
description: 
---

---
description: Ingest zones from GeoJSON (Polygon/MultiPolygon), normalize, and upsert into ZoneKit tables.
---
# Import Zones from GeoJSON

1) Confirm the GeoJSON schema:
   - geometry.type is Polygon or MultiPolygon
   - coordinates are lon/lat
   - properties include identifiers (shapeID, shapeName, etc.)

2) Normalize:
   - Polygon -> MultiPolygon
   - standardize names (trim, collapse whitespace)
   - compute normalized_name for search

3) Validate geometry:
   - correct SRID (4326)
   - valid multipolygon

4) Upsert:
   - stable key: (source, shapeID) or equivalent
   - update boundary + metadata
   - maintain area_m2 and updated_at

5) Verify:
   - sample point containment checks
   - ensure GiST index exists and is used
