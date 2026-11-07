# One room for the bug, the evidence, and the approval

The hardest part of a small production bug is often not writing the fix. It is getting the right context to the right person without losing the thread. One agent can inspect a database, another can read an issue, and a human can approve a change, but if those three pieces live in separate tools, the human becomes the copy-and-paste bus.

I wanted to try a different shape: put the report, the agents, and the decision in the same team chat where the work already happens.

## What I built in a weekend

For Flip the Switch, I built a Supabase connector contribution and a Mattermost bug-triage room template. The demo report is intentionally small: “Signups are failing since 14:00. API returns 500 on POST /auth/v1/signup.” A SQL fixture creates a profile table with a required display name and an Auth trigger that tries to insert the optional signup metadata as-is. A signup without that field fails, just like a real trigger bug can.

The triager classifies the report and checks bounded Supabase Auth and Postgres logs through the remote MCP server. If the evidence points to the database, it hands the investigation to a fixer agent. The fixer inspects, writes a proposed repair into the room, and waits for the owner to approve that exact SQL. Only then does it run the change and verify a new signup.

I chose a signup trigger because it makes the failure concrete without needing a large application or a complicated dataset. Supabase Auth inserts a row into `auth.users`; the demo trigger then writes a profile. The bug is a mismatch between two assumptions: `display_name` is optional input, but the profile column is required. The trigger passes `NULL` through, so Postgres rejects the profile insert and the Auth transaction fails. That gives the triager a traceable database cause rather than a staged screenshot or a simulated error.

The setup also exposes a practical limit. Log availability depends on the project plan and retention window, and an event may not be captured in every source. An empty result cannot prove that nothing failed. The triager therefore checks the Auth and Postgres sources, labels the time window it queried, and reports what it could not assess. It uses a read-only query for schema inspection and keeps the SQL repair separate from diagnosis. Those small habits make the output easier for the owner to review.

The connector follows Switch's service connections catalog design. Supabase's hosted MCP endpoint supports OAuth with dynamic client registration, so the connector can use the owner's existing Supabase sign-in instead of asking them to paste a service-role key. The core server entry is small because Switch's session host handles the MCP call and keeps the credential out of the coding tool.

```yaml
mcp:
  servers:
    - name: supabase
      url: "https://mcp.supabase.com/mcp?features=account,database,debugging"
```

This selects the account, database, and debugging tool groups needed for the demo, without enabling unrelated storage, branching, or feedback groups. Project scope and read-only behavior are explicit choices in the connection. The room instructions require the triager to inspect only and require the fixer to wait for approval before any write.

The details matter. Supabase's `query_logs` runs against the unified ClickHouse `logs` table, not the Postgres database. Auth events live under `auth_logs`; database errors live under `postgres_logs`. The triager supplies an explicit bounded UTC window, since “search the logs” is otherwise ambiguous and can scan too much. The MCP server also exposes account, database, and debugging groups, so the room instructions tell agents which calls are read-only and require the fixer to wait before any write.

## The demo

_Add a short GIF or video here after recording._

The useful moment is the pause. The fixer has enough context to prepare a repair, but it cannot interpret a handoff or a 👍 as permission. It posts the exact SQL, explains the effect, and asks the owner. The owner approves in the incident thread; everyone can see what was agreed and what ran.

## What Switch's room abstraction unlocks

Switch makes a room the shared work surface for both people and agents. The triager does not need a private prompt copied from the incident ticket, and the fixer does not need a second handoff in a different tool. Addressing sends the database bug to a specifically named teammate, while the owner's approval remains visible where the report began. The conversation is also a useful audit trail: symptom, evidence, proposed change, decision, and result.

That structure changes the role of the human. The owner is not asked to trust a hidden chain of tool calls or to reconstruct what the agent saw. They can inspect the evidence and the exact statement in the same room before authorizing it.

It also makes a boundary visible. Agents can be addressed by their work role, but the fixer is configured as `owner-agents`: its conversations can be reached by the room owner and the owner's agents. The owner sees the handoff and can stop the change before execution. If the proposed SQL changes after review, the earlier approval no longer applies. A clear approval record is more useful than asking the owner to approve a vague task like “fix the signup issue,” because the approved object is the actual statement with a stated effect.

## What I'd build next

I would add a disposable Supabase branch for every reproduction, preserve a short redacted log excerpt as a room artifact, and make the approval gate machine-enforced rather than instruction-enforced. The connector's pass-through tools come from Supabase's MCP server; a future Switch capability could classify each tool by effect and require an approval record for database writes. Until then, this demo keeps the project throwaway, logs bounded, and a human in the loop.

Repository: https://github.com/syther069/switch-supabase-triage-room  
Connector PR: https://github.com/sandbox-quantum/switch/pull/1706
