# open-assistants-lab/homebrew-telemetry

Agent diagnosis for coding runs, installed with Homebrew.

```bash
brew install open-assistants-lab/telemetry/odograph
odograph serve
```

## odograph

A coding agent runs, stalls or fails. odograph records **what it actually did** — phases, timings,
outcomes, failure reasons, context accounting — so "why did that run fail?" has an answer after the
fact instead of a scrollback.

Not telemetry for your services: it answers a fixed list of agent questions (why it failed, where the
time went, how close to the context budget, which tool call ended uncertain, what was lost), with a
web UI and a CLI over the same typed API. **0.1.6 has one query engine and no SQL**, so the typed
commands are the whole surface and a question no typed answer covers is reported as a gap rather than
answered with a query you invented.

It listens on OTLP because that is what the agent already speaks — the transport is the input, not
the point. Reads of Etti's canonical store go through Etti's own bounded `etti inspect` protocol;
odograph never opens that file.

Etti finds it automatically through an advertisement file, so no configuration is needed, and Etti
keeps working with odograph absent, stopped or full.

- Data: `~/.local/share/odograph` (28-day retention plus a disk bound; 0600 token, 0700 directory)
- Delete everything: remove that directory. `brew uninstall` does not.
- Start it yourself: `odograph serve`. There is no background service.

## The content lane is opt-in, and it stores content

Operational records hold phases, timings, outcomes and counts — never prompts or output. Content is a
**separate, derived lane** that is off unless you grant it:

```bash
odograph serve --etti-inspector /abs/path/etti --etti-state ~/.local/share/etti/instances/<name> \
               --allow-content <name>
```

With a grant, prompts, model output, tool arguments and results, and reasoning are pulled through
`etti inspect` and stored locally, so the run pages can show what was said and done. Without a grant
nothing is pulled. The lane is a rebuildable copy, not a second authority; `odograph content delete
--run <id> | --all` is the delete path, and deleting cannot recall content already handed to an agent.
Anyone with local access to the store can read it, reasoning included — this is trusted same-UID
development, not a sandbox.

## Platforms

macOS arm64 and Linux x86_64 (static musl, no glibc floor). Each release archive is target-specific
because SQLite is compiled in; there is no universal binary.

The formula's version, archive names and SHA-256 digests are always the built ones, generated from
the project's `packaging/` directory and checked after upload — no digest is ever hand-edited. The
caveat prose may be corrected after render without touching the archives, and this release's caveats
were; the archives behind these digests are exactly the bytes that were built and run-verified.
