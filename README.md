# Supabase signup triage with Switch

This repo is a small, reproducible bug-triage room for a broken Supabase signup flow. A person reports the failure in Mattermost, a triager uses Switch and the Supabase connector to inspect bounded project logs and advisor findings, and a second Claude Code agent proposes a SQL repair. The fixer waits for an explicit `@owner` approval in the same room before it runs any write.

## Workflow

```text
@owner reports signup 500
        |
        v
Mattermost #bug-triage  <---- shared Switch room context ---->  triager (Claude Code)
        ^                                                        | read logs + advisors
        |                                                        v
        +---- approves in thread <---- fixer (Claude Code) <----+ DB bug handoff
                    |                         |
                    +---- explicit approval --+---- SQL repair, then verify signup
```

## How Switch is used

The workflow uses **rooms** to put the owner, triager, and fixer in one Mattermost conversation; the room is the shared record of the report, diagnosis, proposed SQL, and approval. The triager and fixer join as agents through Switch's **agent protocol**, so their harness can be Claude Code while the team stays in Mattermost. **Addressing** routes the database bug from the triager to the fixer by name; the fixer uses `owner-agents`, so only the owner and the owner's agents can address it. **Approvals** happen in the room: the fixer must post the exact SQL, its target and effect, and wait for a clear `@owner` approval before a write call. **Shared context** means both agents can read the original report and the triager's evidence without copying logs into a separate ticket or private agent session.

## Reproduce in about 10 minutes

1. Install [Switch Console](https://github.com/sandbox-quantum/switch/releases/latest) and connect a Mattermost workspace.
2. Connect Supabase through [connector PR #1706](https://github.com/sandbox-quantum/switch/pull/1706). Choose a throwaway project for the demo. The connector uses Supabase's hosted MCP server and OAuth; no service-role key is needed.
3. Load [`rooms/supabase-triage.template.yaml`](rooms/supabase-triage.template.yaml) in Switch Console. Set the provider to Claude Code and the bridge to Mattermost.
4. In the throwaway project's Supabase SQL Editor, run [`scripts/seed-supabase.sql`](scripts/seed-supabase.sql). This creates the profile table and an `auth.users` trigger that fails when optional `display_name` metadata is missing. Use a throwaway project only.
5. Submit a test signup without `display_name`, then paste [`demo/seed-bug.md`](demo/seed-bug.md) into `#bug-triage` as `@owner`.
6. Let the triager check Auth and Postgres logs plus advisor warnings. It should point to the trigger and propose a repair. Review the SQL, reply with an explicit approval, and let the fixer run it. Retry signup and confirm it succeeds.

Use a project-scoped connection and keep tool approval enabled. Log queries need an explicit UTC start and end time. The triager uses `query_logs` for ClickHouse logs (including `auth_logs`, `postgres_logs`, and `edge_logs`) and `execute_sql` only for Postgres inspection. The fixer must not run `execute_sql`, `apply_migration`, or another write tool until `@owner` has approved the exact SQL in the room. A room instruction is a human workflow control; follow the Supabase tool's own confirmation prompt too. The Supabase MCP tool list is not separated into read and write by Switch, so do not grant this connection to agents outside this room.

## Demo video

Demo video: _Add the recording URL here after recording._

## Connector pull request

[Supabase connector PR #1706](https://github.com/sandbox-quantum/switch/pull/1706)

## Contents

- [`rooms/supabase-triage.template.yaml`](rooms/supabase-triage.template.yaml): Switch room and agent template.
- [`agents/triager.instructions.md`](agents/triager.instructions.md): report classification and evidence checklist.
- [`agents/fixer.instructions.md`](agents/fixer.instructions.md): approval-gated SQL workflow.
- [`demo/demo-script.md`](demo/demo-script.md): 90-second narration and recording commands.
- [`demo/seed-bug.md`](demo/seed-bug.md): the incident report to paste into the room.
- [`scripts/seed-supabase.sql`](scripts/seed-supabase.sql): reproducible trigger regression for a disposable project.
- [`SUBMISSION.md`](SUBMISSION.md): hackathon submission details.
- [`blog/post.md`](blog/post.md): first-person blog draft.
- [`social/posts.md`](social/posts.md): X, LinkedIn, and Reddit drafts.

## Safety and cleanup

The SQL fixture targets `auth.users` and intentionally breaks signup until repaired. Run it only in a disposable Supabase project. The repair in the fixer instructions makes profile display names optional and is designed to be repeatable. After recording, remove the demo trigger and table with the cleanup SQL at the end of the seed file or delete the throwaway project from the Supabase Dashboard.
