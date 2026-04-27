# Rook Backend

A small Next.js 16 (App Router) service that proxies the
[BoardGameGeek XML API](https://boardgamegeek.com/wiki/page/BGG_XML_API2)
and caches each response in Upstash Redis. The Rook iOS app talks to
this backend instead of hitting BGG directly so we get:

- a stable JSON shape (`GameDTO`) that decodes 1:1 into the Swift
  `Game` struct,
- a durable cache that survives deploys (BGG `objectid` data is
  effectively immutable),
- a single place to add cross-cutting concerns later (auth, retries,
  rate-limiting, barcode resolution).

## Endpoints

| Method | Path | Purpose |
| ------ | ---- | ------- |
| `GET`  | `/api/games/:id` | Fetch one game by BGG `objectid` |
| `GET`  | `/api/search?q=...&limit=20` | Search BGG and hydrate results |
| `GET`  | `/api/health` | Liveness probe |

Both data endpoints accept `?refresh=1` to bypass the cache read while
still writing through (useful when BGG corrects metadata).

`/api/search` fan-outs: it caches the search-result id list for 7 days,
then for every id it either reads from the per-game cache or fetches
the missing ids in a single `xmlapi2/thing` call. Every game it
hydrates is written into `bgg:thing:{id}` with a 30-day TTL, so a later
`/api/games/:id` for any of those ids is free.

CDN cache headers are set on all responses so Vercel's edge absorbs hot
requests too.

## Cache keys

| Key | Value | TTL |
| --- | ----- | --- |
| `bgg:thing:{id}` | full `GameDTO` JSON | 30 days |
| `bgg:search:{normalizedQuery}:{limit}` | `number[]` of BGG ids | 7 days |

## Vercel project setup

The backend has **two cache layers** and only the first is required:

1. **Vercel CDN edge cache** — driven by the `Cache-Control` headers
   each route sets (`s-maxage=2592000` for `/api/games/:id`,
   `s-maxage=604800` for `/api/search`). Free, no setup, kicks in
   automatically as soon as you deploy. Hot URLs are served from the
   edge in ~30–80 ms without ever invoking the function.
2. **Upstash Redis (optional)** — a per-id durable cache so that
   *search-time fan-out hydration* and arbitrary-URL repeat lookups
   don't re-hit BGG. The route handlers fall back to pass-through mode
   if the env vars aren't set, so this is purely an optimisation.

### Minimum (CDN-only)

1. Create a new Vercel project pointing at this repo.
2. **Set the project root to `backend`** (Settings → General → Root
   Directory). Vercel deploys only this folder; the rest of the repo
   (the iOS Tuist project) is ignored.
3. Optionally add `BGG_BASE_URL=https://boardgamegeek.com/xmlapi2` as
   an env var (defaults to that value in code).
4. Deploy. Done. `/api/health`, `/api/games/:id`, and `/api/search`
   all work; the first request for a given URL warms the CDN.

### Adding Upstash Redis later (free tier)

When you want the second cache layer, from the project's Storage tab:
**Create Database → Marketplace → Upstash for Redis → Free plan**. The
integration auto-provisions `KV_REST_API_URL` and `KV_REST_API_TOKEN`
across Preview + Production. Vercel triggers a redeploy and the
backend transparently starts using Redis on the next request — no code
change needed.

## Local development

```sh
# from the repo root
cd backend
npm install
vercel link            # one-time; pick the Vercel project created above
vercel env pull .env.local   # pulls Upstash + BGG vars
npm run dev
```

Smoke test:

```sh
curl http://localhost:3000/api/health
curl 'http://localhost:3000/api/games/174430' | jq
curl 'http://localhost:3000/api/search?q=wingspan&limit=5' | jq
```

If you do not want to provision Upstash for local dev you can point
`KV_REST_API_URL` / `KV_REST_API_TOKEN` at any Upstash dev database
(or use `upstash/redis-js`'s in-memory mode in a future iteration).

## Scripts

| Script | What it does |
| ------ | ------------ |
| `npm run dev` | Next.js dev server with Turbopack |
| `npm run build` | Production build |
| `npm run start` | Run the production build |
| `npm run typecheck` | `tsc --noEmit` over the whole project |
| `npm run lint` | `next lint` (kept for parity; ESLint config is flat) |

## What is intentionally not here

- **Barcode → BGG resolution**: still mocked on the client. Adding it
  here means calling an external UPC service (UPCitemdb / barcodelookup)
  and mapping the title to a BGG id.
- **Shelf-photo recognition**: still mocked on the client. Will need an
  AI vision provider (OpenAI / Gemini / Claude) and is large enough to
  warrant its own endpoint.
- **Auth**: endpoints are read-only over public BGG data. If abuse
  becomes a problem, gate behind a shared header issued by the iOS
  build pipeline.
