---
description: 
---

---
description: Resolve a free-text location string to one or more candidate zones using normalization + trigram similarity + tie-breakers.
---
# Resolve Location Text to Zone

1) Normalize input:
   - lower-case
   - trim, collapse whitespace
   - remove punctuation noise
   - optionally transliteration rules (if the app defines them)

2) Candidate search:
   - trigram similarity over zone normalized_name (and aliases if modeled)
   - apply thresholding

3) Tie-breakers:
   - prefer zones in the user’s known country/city context if available
   - prefer “more specific” types when user intent implies specificity
   - if still ambiguous, return top N candidates for disambiguation

4) Persist optional cache entry for (normalized_input, context) -> zone_id.

5) Verify:
   - explain why the chosen zone won
   - confirm indexes exist for the query shape
