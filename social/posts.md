# #HowISwitch drafts

## X

I built a Supabase bug-triage room in Mattermost with Switch: one agent checks bounded logs, another proposes a SQL fix, and the owner approves it in the same thread before it runs. One shared room keeps evidence and decisions together. #HowISwitch

## LinkedIn

I built a small Supabase signup incident workflow with Switch and Mattermost. The report, two Claude Code agents, the log evidence, and the human approval all stay in one room.

The triager checks Auth and Postgres logs through Supabase's MCP connector. The fixer proposes the exact SQL, explains its effect, and waits for the owner before running a write.

I like that the workflow makes the handoff visible instead of copying context between tools. The repo includes the room template and a disposable SQL fixture. #HowISwitch

## Reddit — r/programming

I put together a small demo of incident triage in Mattermost using Switch. It connects a Supabase MCP server to two Claude Code agents: one checks Auth and Postgres logs, then hands database bugs to a fixer. The fixer posts the proposed SQL and waits for the room owner to approve the exact statement before running it.

The included SQL fixture creates a signup failure with an `auth.users` trigger that assumes optional metadata is present. I am interested in whether keeping the report, evidence, and approval in one shared room makes the handoff easier to review. The repo and connector PR links are in the README.
