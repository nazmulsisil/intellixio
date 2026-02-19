---
description: 
---

---
description: Run a Turbo task safely (scoped by app/package) and report results.
---
# Turbo Run (Scoped)

1) Identify the target package/app.
   - Prefer a single target unless the user explicitly wants a broad run.

2) Choose the task:
   - build, dev, lint, check-types, test, format (confirm tasks exist in turbo.json)

3) From repo root, run one of:
   - pnpm turbo run <task> --filter=<package-name>
   - pnpm turbo run <task> --filter=./apps/<app>
   - pnpm turbo run <task> --filter=<package-name>...   (include deps)
   - pnpm turbo run <task> --filter=...<package-name>   (only dependents)

4) If it fails:
   - capture the first actionable error
   - propose the smallest fix
   - re-run the same scoped command
