# ZoneKit API

This is the internal spatial resolution and tagging service for the Zendolead platform.

## `GET /healthz`

> **Last Updated: 2026-02-20**

The `GET /healthz` endpoint serves as a health check to verify the service status, including its connection to the database.

**Request:**
```bash
curl http://localhost:4000/healthz
```

**Response (Healthy DB):**
```json
{
  "ok": true,
  "db": true
}
```

**Response (Unhealthy DB):**
HTTP Status `503 Service Unavailable`
```json
{
  "ok": true,
  "db": false
}
```

---

## `POST /v1/resolve-zone`

> **Last Updated: 2026-02-20**

The `POST /v1/resolve-zone` endpoint uses trigram similarity (`pg_trgm`) to match unstructured location strings to normalized administrative zones in the database.

It evaluates the input against thresholds to determine whether to return a single *definitive* match, or multiple *ambiguous* candidates.

### Thresholds
These rules govern the resolution, configurable via Environment Variables in `.env`:
1. `RESOLVER_MIN_TOP_SCORE` (Default: `0.35`): The minimum required similarity score for the best candidate. If the top match is below this, it is rejected entirely.
2. `RESOLVER_MIN_MARGIN` (Default: `0.08`): The required gap in score between the #1 match and the #2 match. If the gap is smaller than this threshold, the result is considered "ambiguous".
3. `RESOLVER_MAX_CANDIDATES` (Default: `3`): The maximum number of candidates returned when the result is ambiguous.

---

### Example 1: Definitive Match
When the text perfectly or closely matches a single zone.

**Request:**
```bash
curl -X POST http://localhost:4000/v1/resolve-zone \
  -H "Content-Type: application/json" \
  -d '{"text": "Dhaka"}'
```

**Response:**
```json
{
  "resolved": true,
  "zone": {
    "id": "1234-abcd...",
    "name": "Dhaka",
    "normalized": "dhaka",
    "admin_level": 2,
    "area_m2": 150000000,
    "score": 1.0
  },
  "reason": "Single strong candidate found."
}
```

### Example 2: Typo (Still Definitive)
When the text has a typo, but it's still clearly the best match by a wide margin.

**Request:**
```bash
curl -X POST http://localhost:4000/v1/resolve-zone \
  -H "Content-Type: application/json" \
  -d '{"text": "Dhhaka City"}'
```

**Response:**
```json
{
  "resolved": true,
  "zone": {
    "id": "1234-abcd...",
    "name": "Dhaka",
    "normalized": "dhaka",
    "admin_level": 2,
    "area_m2": 150000000,
    "score": 0.65
  },
  "reason": "Top candidate exceeded runner-up by margin of 0.250."
}
```

### Example 3: Ambiguous Match
When the text could refer to multiple different places, and the database has similarly scored candidates (often due to shared prefixes or names).

**Request:**
```bash
curl -X POST http://localhost:4000/v1/resolve-zone \
  -H "Content-Type: application/json" \
  -d '{"text": "Mirpur"}'
```

**Response:**
```json
{
  "resolved": false,
  "candidates": [
    {
      "id": "...",
      "name": "Mirpur 1",
      "normalized": "mirpur 1",
      "admin_level": 3,
      "area_m2": 5000000,
      "score": 0.55
    },
    {
      "id": "...",
      "name": "Mirpur 2",
      "normalized": "mirpur 2",
      "admin_level": 3,
      "area_m2": 4500000,
      "score": 0.55
    }
  ],
  "reason": "Ambiguous match. Margin (0.000) is below the required threshold (0.08)."
}
```

### Example 4: Meaningless/Weak Match
When the text doesn't resemble anything in the database closely enough.

**Request:**
```bash
curl -X POST http://localhost:4000/v1/resolve-zone \
  -H "Content-Type: application/json" \
  -d '{"text": "asdfghjkl"}'
```

**Response:**
```json
{
  "resolved": false,
  "candidates": [ ... ],
  "reason": "Top candidate score (0.12) is below the minimum threshold (0.35)."
}
```

---

## `POST /v1/tag-product`

> **Last Updated: 2026-02-20**

The `POST /v1/tag-product` endpoint tags a product with the spatial zones that intersect its coordinates (latitude and longitude).

It evaluates the point `[lng, lat]` against the `zendolead.zones` table using a `ST_Covers` PostGIS query to find all intersecting zones and the specific "leaf zone" (the zone with the smallest area). It then upserts these results into the `zendolead.product_geo` table.

### Requirements & Authorization
- **Feature Flag**: Write operations are gated behind the `ZONEKIT_TAGGING_ENABLED=true` environment variable.
- **`x-zonekit-key`**: Requests must include the internal API key in this header matching the `ZONEKIT_INTERNAL_API_KEY` environment variable.

**Request:**
```bash
curl -X POST http://localhost:4000/v1/tag-product \
  -H "Content-Type: application/json" \
  -H "x-zonekit-key: <internal-api-key>" \
  -d '{
    "productId": "prod_123",
    "lat": 23.8103,
    "lng": 90.4125
  }'
```

**Response:**
```json
{
  "success": true,
  "productId": "prod_123",
  "leafZoneId": "zone_123_smallest_area",
  "zoneIds": [
    "zone_123_smallest_area",
    "zone_456_larger_area",
    "zone_789_largest_area"
  ]
}
```

