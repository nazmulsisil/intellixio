---
description: 
---

---
description: Compute zone_ids for a pin (lat/lng) and store multi-zone + leaf-zone tagging.
---
# Tag Product Pin with Zones

1) Convert pin to geometry point (SRID 4326).
2) Find all zones that contain/cover the point.
3) Persist:
   - zone_ids[] = all containing zones ordered by specificity
   - leaf_zone_id = best “smallest/specific” zone (using hierarchy first; fallback to smallest area)

4) If no zones match:
   - store empty array
   - optionally assign a configured fallback (e.g., city-level) only if business rules allow

5) Verify:
   - deterministic results for the same point
   - query uses GiST boundary index
