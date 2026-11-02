# open-assistants-lab/homebrew-telemetry

Homebrew tap for local **telemetry and diagnostics** tooling.

```bash
brew install open-assistants-lab/telemetry/odograph
```

## odograph

Local operational diagnostics for coding agents: a bounded local store of what a run did — phases,
timings, outcomes, failure reasons, context numbers — a web UI, a CLI and guarded read-only SQL.
No account, no egress, no telemetry of its own.

It stores operational facts only: never prompts, model output, tool arguments, reasoning or
receipts. Etti finds it automatically through an advertisement file, so no configuration is needed,
and Etti keeps working with odograph absent, stopped or full.

- Data: `~/.local/share/odograph` (28-day retention plus a disk bound; 0600 token, 0700 directory)
- Delete everything: remove that directory. `brew uninstall` does not.
- Start it yourself: `odograph serve`. There is no background service.

Formula source is generated from the project's `packaging/` directory; each release archive is
arch-specific because DuckDB is statically linked.
