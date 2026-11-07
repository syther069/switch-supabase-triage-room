Signups are failing since 14:00. API returns 500 on POST /auth/v1/signup.

This is the throwaway Supabase project for the demo. I can reproduce with a new email signup that has no `display_name` in user metadata. Please check the Auth and Postgres logs around 14:00 UTC, classify the cause, and propose a fix. Do not run any write until I approve the exact SQL here in the room.
