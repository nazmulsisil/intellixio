---
name: location-resolver
description: Use this skill when implementing or reviewing the text-to-zone resolver; apply normalization, trigram search, tie-breakers, and caching.
---
# Location Resolver

## Goal
Resolve user location text to the most likely zone(s) with explainable, deterministic rules.

## Instructions
1) Normalize input consistently.
2) Query candidates using pg_trgm similarity on normalized_name (and aliases if modeled).
3) Apply context-aware tie-breakers (country/city/type).
4) Return:
   - single best zone when confident
   - otherwise a ranked candidate list with short reasons
5) Cache resolutions where it improves performance without sacrificing correctness.

## Guardrails
- Do not “invent” zones; only return zones present in schema-backed tables.
- Prefer explicit disambiguation over overconfident guesses.

## Output format
- “Normalized input”
- “Candidate list (ranked)”
- “Decision/tie-break explanation”
- “Cache behavior (if any)”
