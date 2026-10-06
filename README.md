# Deploy and Host OpenReplay on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/openreplay?utm_medium=integration&utm_source=button&utm_campaign=openreplay)

[OpenReplay](https://openreplay.com/) is open-source session replay: watch exactly what a user did in your web app, with the console, network requests, errors and performance data playing alongside. It also does product analytics (funnels, journeys, heatmaps, dashboards). This template runs OpenReplay v1.28.0 on your own Railway project, so recordings never leave your infrastructure.

## About Hosting OpenReplay

- **Session replay without a third party.** Recordings, user data and analytics live in your own Postgres, ClickHouse and object storage on Railway's private network. Only the dashboard and the tracker ingest endpoint are public.
- **One public URL.** A gateway serves the dashboard, takes tracker data at `/ingest`, proxies the tracker script at `/script` and hands out signed recording downloads, all on the same domain.
- **Upstream's own pipeline.** Ingest, sink, storage, ender, db, assets, canvases and the Go API run as in OpenReplay's docker-compose install, with Redis streams as the queue. There is no Kafka to run.
- **Pinned and self-migrating.** Every image is pinned to v1.28.0. The Postgres schema, ClickHouse schema and storage buckets are created on first boot.

## Common Use Cases

- Reproducing bugs from support tickets by replaying the user's session with the console and network logs
- Finding where users drop off with funnels, journeys and click maps
- Session replay and analytics for products that can't send user data to a SaaS (GDPR, healthcare, internal tools)

## Dependencies for OpenReplay Hosting

- Postgres 17 (included, private network only)
- ClickHouse 26.2 (included, private network only)
- Redis 8 (included, private network only)
- RustFS S3-compatible object storage (included, private network only, the same server OpenReplay's own install uses)

### Deployment Dependencies

- [OpenReplay documentation](https://docs.openreplay.com/)
- [Tracker setup guide](https://docs.openreplay.com/en/sdk/)
- [OpenReplay on GitHub](https://github.com/openreplay/openreplay)
- [Template source on GitHub](https://github.com/nomideusz/openreplay-railway)

### Implementation Details

**Open the OpenReplay service's Railway domain** once all services are up. The first boot creates the database schemas and storage buckets, which takes a minute or two. You land on an installation check. Click **Create Account**: the first account becomes the owner of the organization. After that, new users join by invitation only.

**Add the tracker to your site.** The dashboard shows a project key and a ready-made snippet. Point it at your deployment:

```js
import { tracker } from '@openreplay/tracker';

tracker.configure({
  projectKey: 'YOUR_PROJECT_KEY',
  ingestPoint: 'https://your-openreplay.up.railway.app/ingest',
});
tracker.start();
```

A session appears in the dashboard a few minutes after the visitor leaves, once OpenReplay has closed and stored it.

**Services.** OpenReplay (gateway and dashboard), Backend (OpenReplay's Go services in one container), API (OpenReplay's Python API), ClickHouse, Postgres, Redis and Storage. The Go services share the Backend container because they hand recordings to each other through a shared directory, and Railway volumes can't be shared between services.

**Not included:** Assist (live co-browsing and calls), the source map reader for de-minified error stack traces, email alerts, Spot (the Chrome extension recorder) and mobile session screenshots. Web session replay, product analytics, dashboards and canvas recording all work without them.

**Memory.** About 650 MB at idle: ClickHouse 250 MB, API 110 MB, Backend 100 MB, Postgres 80 MB, Storage 70 MB. That is more than the Trial plan gives, so deploy on Hobby or above. Usage grows with traffic: plan for more as recordings come in.

**Email.** Invitations and password resets need SMTP. Set `EMAIL_HOST`, `EMAIL_USER` and `EMAIL_PASSWORD` on the API service. Railway only allows outbound SMTP on the Pro plan.

**Custom domain.** Add it in the OpenReplay service's Settings → Networking, then set `SITE_URL` on the API service to `https://your.domain`. Use the new domain as your tracker's `ingestPoint`. Recording links keep going through the Railway domain, which stays active.

**Keep the secrets.** `JWT_SECRET`, `TOKEN_SECRET` and the other generated secrets sign logins and tracker sessions. Changing them logs everyone out and invalidates in-flight sessions.

## Why Deploy OpenReplay on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying OpenReplay on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
