# Architecture

- `apps/web` — Next.js 15, deployed on Vercel.
- Data today: a single Postgres on Neon, accessed with Drizzle. ~40k rows, one region.
- **The live-map feature needs real-time sync between two to five collaborators per trip.**
- No self-hosting requirement. One engineer. Budget is $300/month for everything.
