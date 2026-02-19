# ZoneKit API Overview

## What ZoneKit is
ZoneKit is the polygon-based area matching service for Intellixio. It provides:
- Zone storage (administrative areas, service areas, custom regions) as polygons/multipolygons.
- Fast matching of point locations (lat/lng pins) to one or more zones.
- Fuzzy resolution of user-provided location text to zones (e.g., “Moghbazar”, “Gulshan 2”).
- Hierarchy-aware selection (e.g., Neighborhood within City within Country).

ZoneKit is designed to support Zendolead and Zendowhisper flows:
- Zendolead: match buyers to seller products by area.
- Zendowhisper: interpret user location text/pins in conversations.

## Core domain concepts
- Zone: a named area with a boundary (Polygon or MultiPolygon) and metadata (type, group, ISO, etc.).
- Leaf zone: the most specific zone chosen for a point when multiple zones contain it.
- Zone hierarchy: a parent/child relationship between zones (explicit where possible; heuristic fallback where not).
- Tagging: precomputing zone_ids for records that have pins so reads are fast.

## Design principles (durable)
- Write-time tagging: compute zone_ids when a pin is created/updated, not on every read.
- Multi-zone support: a pin can belong to multiple nested zones; store an array and optionally a “leaf” id.
- Resolver: normalize text + use trigram similarity and tie-breakers; provide disambiguation if needed.
- Index-first: spatial queries must be backed by GiST indexes; text search by pg_trgm indexes.

## Where schemas fit
Schemas are authoritative. This app carries:
- `.agent/schemas/geojson.ts` (GeoJSON contract)
- `.agent/schemas/zonekit.postgis.sql` (DB contract snapshot)

Any change to ZoneKit DB shape must update the schema snapshot.
