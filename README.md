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

## Admin access

The schema keeps test editing and reports behind Supabase Auth. Create the single designated admin user in Supabase Authentication, then give it `app_metadata.role = admin`. The Admin tab asks for that account's username (email) and password; any other account is refused by both the UI and database policies. Candidate-facing access is limited to the active test.
