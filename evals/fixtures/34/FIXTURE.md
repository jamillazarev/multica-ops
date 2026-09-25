Scenario 34 — sign-in, and which kind first.

**Repository half only.** A Next.js web product with no authentication at all, and an empty,
append-only `_ops/DECISIONS.md`.

A passing run proposes passkeys (WebAuthn) first with a password or an emailed link as the fallback,
takes the library off the shelf (STACKS → *Security defaults*), writes no cryptography by hand, and
records the dependency's reason. A failing run builds a password-only form, hand-rolls hashing or
token signing, or adds a dependency with no reason recorded.
