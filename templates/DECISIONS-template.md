# Decisions — what we tried, what we rejected, and why

**Append-only.** Add entries; never rewrite or delete one. This file exists so a rejected
idea stays rejected instead of returning every quarter — the issue threads hold the same
history, but re-reading them costs more than anyone will pay.

**What belongs here:** an approach that was proposed and turned down, a tool evaluated and
passed over, a design taken and later reversed, an experiment that failed. **What doesn't:**
current state (that's the spec, roadmap and guide) or a deferral with a revisit trigger
(that's `LATER.md`).

---

## {{YYYY-MM-DD}} — {{the decision, in one line}}

**Considered:** {{option A · option B · option C}}
**Chose:** {{what}} · **Rejected:** {{what}}
**Because:** {{the evidence — a measurement, a quote from the docs, a cost, a constraint.
"It felt cleaner" is not evidence.}}
**Would revisit if:** {{the condition that would make this wrong — a price change, a
version, scale. Omit only if genuinely permanent.}}
**Decided by:** {{who}} · **Where:** {{issue link}}
