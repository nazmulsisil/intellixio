---
trigger: always_on
---

# Monorepo Scope Rules

## What “scoped” means here
A scoped change:
- targets a single app under `apps/` OR a single package under `packages/`
- avoids unrelated formatting churn
- avoids dependency sprawl

## Cross-cutting change requirements
Only do cross-cutting changes when necessary. If unavoidable:
- explain why the work cannot remain local
- minimize changes to shared contracts
- validate impacted dependents (at least build + typecheck)

## Working in product-specific apps
If the request is specific to one product, prefer opening Antigravity from that app folder so the app-level `.agent` rules apply (if present).
