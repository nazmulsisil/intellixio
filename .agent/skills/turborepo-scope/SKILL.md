---
name: turborepo-scope
description: Use this skill when asked to change code in the monorepo; determine the minimal set of apps/packages affected and how to run Turbo tasks with filters.
---
# Turborepo Scope Enforcer

## Goal
Keep changes small, local, and verifiable in a Turborepo monorepo.

## Instructions
1) Identify the primary target:
   - an app in `apps/` OR a shared package in `packages/`.
2) Determine secondary impacts:
   - shared packages imported by the target
   - downstream dependents if a shared package is modified
3) Define the minimal verification set:
   - lint + typecheck for the target
   - build/test if applicable
4) Provide exact Turbo commands using `--filter`.
5) Reject cross-app imports:
   - if an app needs another app’s code, extract a shared package.

## Output format
- “Target scope”
- “Impacted packages”
- “Commands to run”
- “Notes / risks”
