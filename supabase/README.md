Supabase env usage

1. Copy `.env.example` to `.env` or create `.env.local`.
2. Fill `SUPABASE_URL` and `SUPABASE_ANON_KEY` with your project values.
3. In the browser build, include `supabase/config.js` which reads `window.SUPABASE_CONFIG`.

Notes:
- For local development you can load variables into `window.SUPABASE_CONFIG` manually or use a small dev script to inject them.
- Do NOT commit your real keys to public repos.
