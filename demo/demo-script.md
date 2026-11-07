# 90-second demo narration

## Narration and actions

**0:00** — “This is Switch. My team's bug triage room, in Mattermost.” Show `#bug-triage` with the owner and both Claude Code agents.

**0:10** — As `@owner`, paste `demo/seed-bug.md`. Mention that the fixture is running on a throwaway Supabase project.

**0:20** — “The triager checks the Supabase evidence before guessing.” Show it querying `auth_logs` and `postgres_logs` through the Supabase connector with a bounded UTC window, then reading the relevant schema and advisor warnings.

**0:40** — The triager classifies the incident as a database bug and hands the report and evidence to `@supabase-fixer` by mention.

**0:55** — “The fixer can prepare a repair, but it cannot act on an implied yes.” Show the fixer posting the exact `create or replace function` SQL, naming its target and effect, then waiting.

**1:10** — As `@owner`, approve that exact SQL in the thread. Show the fixer run it, verify the function, and retry signup. The next signup succeeds.

**1:25** — “All of this happened in one chat room because Switch was in it.” End on the shared report, evidence, approval, and verification.

## Recording checklist

- Use a fresh Mattermost channel and a throwaway Supabase project only.
- Run `scripts/seed-supabase.sql` in the Supabase SQL Editor before recording. Enable email signups, then test a new signup without `display_name` metadata.
- Make sure logs are available for the selected time range. Set the sample report's start time to match the recording, and say UTC explicitly.
- Keep tool confirmation prompts enabled. Show the owner approving the exact SQL in chat and any separate MCP confirmation.
- Capture the room, evidence, approval, and successful retry in `demo/screenshots/` if still images are useful. The `.gitignore` intentionally leaves those recording artifacts untracked until selected.
- Do not expose project references, emails, tokens, keys, or connection strings in the recording.

## Optional shell commands

From the repository root, inspect the SQL before pasting it into the Dashboard:

```powershell
Get-Content .\scripts\seed-supabase.sql
```

If `psql` is installed and `SUPABASE_DB_URL` is already set for the throwaway project, apply the fixture from PowerShell without putting the URL in shell history:

```powershell
psql "$env:SUPABASE_DB_URL" -v ON_ERROR_STOP=1 -f .\scripts\seed-supabase.sql
```

Do not use a production database URL. The Dashboard SQL Editor is the recommended path for a first run.
