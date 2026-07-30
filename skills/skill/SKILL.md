---
description: The toolkit's lifecycle — create from a routine, screen an import, compress fail-closed, release.
---

Load and follow the **multica-ops** skill (`../mops/SKILL.md`), executing its `/multica-ops:skill` flow
(PLAYBOOKS → "The skill lifecycle"). Pick the operation from the argument — `create`,
`import`, `optimize`, `release` — or infer it and confirm. Gates are not optional: an
imported skill is screened and read before it is attached, compression preserves commands,
paths, numbers and security rules verbatim and is reviewed by someone other than the
compressor, and a release is de-identified and owner-confirmed before anything leaves.
