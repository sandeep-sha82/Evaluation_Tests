# Assessly

A React + Supabase evaluation platform. Candidates can take the currently active test; administrators can create multiple tests, define duration and scoring, activate one, and export submissions as CSV.

## Run locally

1. Copy `.env.example` to `.env` and add your Supabase project URL and anonymous key. (Without these, the app starts in a polished demo mode.)
2. Run `npm install` and `npm run dev`.
3. In Supabase, open **SQL Editor** and run `supabase/schema.sql`.

## Deploy to Netlify

1. Push this folder to GitHub and import it in Netlify.
2. Build command: `npm run build`; publish directory: `dist`.
3. In Netlify site configuration, add `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` from your Supabase project settings.
4. Trigger a new deploy.

## Bulk questions, AI generation, and media

- In the test editor, **Import CSV** accepts columns: `question`, `option_a`, `option_b`, `option_c`, `option_d`, and `correct_answer` (A, B, C, or D). Optional `media_url` and `media_type` columns are also supported.
- The editor lets admins attach an audio or video file to any individual question. On an existing project, run `supabase/upgrade-media.sql` once; on a fresh project, use the full `supabase/schema.sql`.
- AI generation uses a Netlify Function so the OpenAI key is never exposed in the browser. In Netlify environment variables set `OPENAI_API_KEY`, `SUPABASE_URL`, and `SUPABASE_ANON_KEY`, plus optional `OPENAI_MODEL`. Locally, AI generation needs `netlify dev` (with the same values in `.env`) rather than `npm run dev`.

## Admin access

The schema keeps test editing and reports behind Supabase Auth. Create the single designated admin user in Supabase Authentication, then give it `app_metadata.role = admin`. The Admin tab asks for that account's username (email) and password; any other account is refused by both the UI and database policies. Candidate-facing access is limited to the active test.
