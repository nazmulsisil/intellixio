# Polygon-Based Matching (ZoneKit)

## Problem
Free-text locations and raw pins are not enough for reliable area matching:
- Text is ambiguous and inconsistent.
- Pins need deterministic containment queries.

## Durable approach
1) Store zones as PostGIS geometries (MULTIPOLYGON, SRID 4326).
2) When a record has a pin (lat/lng), compute:
   - point geometry
   - all containing zones (zone_ids[])
   - a “leaf zone” chosen by hierarchy/smallest area
3) For text-only locations:
   - normalize text
   - find candidate zones by trigram similarity
   - apply tie-breakers (country/city context, type priorities, popularity, hierarchy)
   - cache resolutions

## Output expectations
- Matching results should be deterministic given the same inputs and schema snapshot.
- Disambiguation should be supported when multiple candidates are plausible.
- Performance targets assume:
  - GiST on zone boundary
  - avoiding heavy spatial computation on hot read paths
