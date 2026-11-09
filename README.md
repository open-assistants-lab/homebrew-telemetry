# open-assistants-lab/homebrew-telemetry

Agent diagnosis for coding runs, installed with Homebrew.

```bash
brew install open-assistants-lab/telemetry/odograph
```

## odograph

A coding agent runs, stalls or fails. odograph records **what it actually did** — phases, timings,
outcomes, failure reasons, context accounting — so "why did that run fail?" has an answer after the
fact instead of a scrollback.

Not telemetry for your services: it answers a fixed list of agent questions (why it failed, where the
time went, how close to the context budget, which tool call ended uncertain, what was lost), and names
the two it cannot answer yet. A web UI, a CLI, and guarded read-only SQL over the same API.

It listens on OTLP because that is what the agent already speaks — the transport is the input, not
the point.

It stores operational facts only: never prompts, model output, tool arguments, reasoning or
receipts. Etti finds it automatically through an advertisement file, so no configuration is needed,
and Etti keeps working with odograph absent, stopped or full.

- Data: `~/.local/share/odograph` (28-day retention plus a disk bound; 0600 token, 0700 directory)
- Delete everything: remove that directory. `brew uninstall` does not.
- Start it yourself: `odograph serve`. There is no background service.

Formula source is generated from the project's `packaging/` directory; each release archive is
arch-specific because DuckDB is statically linked.
