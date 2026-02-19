---
description: 
---

---
description: Standard “ready to merge” checklist for a scoped change.
---
# PR Ready Checklist

1) Ensure the change is scoped:
   - only touched necessary apps/packages
   - no unrelated refactors

2) Run scoped checks (from repo root):
   - pnpm turbo run lint --filter=<target>
   - pnpm turbo run check-types --filter=<target>
   - pnpm turbo run test --filter=<target>   (if tests exist)
   - pnpm turbo run build --filter=<target>  (if build applies)

3) If a shared package was changed:
   - run checks for at least one downstream dependent app/package

4) Confirm schema snapshots were updated if DB changes were made.

5) Summarize:
   - what changed
   - why it changed
   - how to verify
