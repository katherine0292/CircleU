# Agent collaboration log

This is CircleU's durable work and handoff record, adapted from section 13 of the shared coding standard. It records meaningful work and actual agent review discussions. It is maintained by agents/contributors; no automatic capture service or transcript export is installed.

## Read and write

1. At task start, read `../../AGENTS.md`, the project standards and the latest entries relevant to the task. Follow unresolved handoff references, not just the newest filename.
2. After meaningful work, a review exchange or a handoff, create `YYYY-MM-DD-HHMMSS-agent-topic.md`. Use Australia/Sydney time with UTC offset in the entry. Add a unique suffix if a filename already exists; never overwrite it.
3. Use [the template](TEMPLATE.md). Record the request, scope/files, outcome, evidence, decisions and next action. A brief entry is enough for a small task; do not log every command or minor thought.
4. Describe actual agent exchanges with participants, finding/request, response, resolution and remaining owner. If none occurred, write “None.” Do not manufacture review sign-off or reconstruct unavailable conversations.
5. Published entries are append-only. Add a dated follow-up or new linked entry for corrections and superseded decisions. Never silently repair the historical record. This README and the blank template are maintained normally.

Use links to repository evidence and PRs when available. For a working-tree change without a commit, say so; never invent a commit or task ID. Report completed checks separately from planned ones, and identify claims inherited from earlier sessions.

## Coordination and privacy

- Log only concise work/review summaries, not raw chats, hidden reasoning, large tool output or private app data. Redact credentials and personal content before writing.
- A handoff names a role/agent only when assigned; otherwise use “Unassigned.” An entry is not proof another agent received or accepted a task.
- No automatic delegation or messaging is authorized by this folder. Follow the user's task and tool permissions.
- For concurrent work, use separate files, record the base revision and owned paths, and have the integrating agent record the final verification. Do not claim work is complete solely because another agent said so.
- If sensitive content is accidentally logged, stop propagating it and arrange authorized redaction/remediation; append-only history is not a reason to retain a secret. Record a sanitized incident note.

## Starting record

- [Retrospective discovery and MVP planning](2026-10-23-retrospective-codex-mvp-planning.md): available conversation/document evidence before this log existed. It is not a verbatim conversation archive or an independent rerun of earlier checks.

Find newer entries by filename/date. Each new entry can link directly to its predecessors without editing a shared index. The [documentation index](../README.md) remains the navigation hub for current product and technical truth.
