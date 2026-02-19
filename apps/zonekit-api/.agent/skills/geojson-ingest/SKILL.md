---
name: geojson-ingest
description: Use this skill when importing or validating GeoJSON zones; enforce Polygon/MultiPolygon handling, normalization, and safe upsert patterns.
---
# GeoJSON Ingest

## Goal
Reliably ingest GeoJSON shapes into ZoneKit with deterministic normalization and validation.

## Instructions
1) Validate input against `.agent/schemas/geojson.ts`.
2) Normalize all geometries to MULTIPOLYGON (SRID 4326).
3) Compute normalized search fields (normalized_name).
4) Upsert by stable external id (shapeID) plus source namespace.
5) Ensure spatial + text indexes are present.
6) Provide a verification plan (spot-check points + explain index usage).

## Guardrails
- Never assume coordinate order is lat/lng; treat it as lon/lat.
- Never silently drop invalid polygons; surface errors and require explicit repair rules.

## Output format
- “Validation results”
- “Normalization applied”
- “Upsert keys”
- “Indexes required”
- “Verification commands/steps”
