# open-assistants-lab/homebrew-telemetry

Agent diagnosis for coding runs, installed with Homebrew.

```bash
brew install open-assistants-lab/telemetry/runwatch
runwatch serve
```

## runwatch — renamed from odograph in 0.2.0

The product, the formula and the binary are `runwatch` from 0.2.0. `formula_renames.json` maps
`odograph` → `runwatch`, so an installed `odograph` is migrated to `runwatch` by the tap instead of
leaving two formulas installed.

**0.2.0 is a hard break, not an alias.** `runwatch` does not read a legacy advertise file, does not
accept the old credential names, and does not use the old data directory — an upgrade therefore starts
a fresh store. The old `~/.local/share/odograph` directory is left untouched; delete it when you no
longer want the 0.1.x history.

| contract value | 0.2.0 |
|---|---|
| formula, binary | `runwatch` |
| data directory | `$XDG_DATA_HOME/runwatch`, else `~/.local/share/runwatch` (file name stays `advertise.json`) |
| advertisement schema | `runwatch.advertise.v1` |
| credential header, cookie | `x-runwatch-token`, `runwatch_session` |
| content consents | `runwatch-content-1`, `runwatch-content-2` |
| inspect temp prefix | `runwatch-inspect-` |
| environment | `RUNWATCH_ENGINE`, `RUNWATCH_DATA_DIR`, `RUNWATCH_RELEASE_TARGET_DIR` |

HTTP route paths are unchanged, so an OTLP sender keeps working without a change.

## runwatch

A coding agent runs, stalls or fails. runwatch records **what it actually did** — phases, timings,
outcomes, failure reasons, context accounting — so "why did that run fail?" has an answer after the
fact instead of a scrollback.

Not telemetry for your services: it answers a fixed list of agent questions (why it failed, where the
time went, how close to the context budget, which tool call ended uncertain, what was lost), with a
web UI and a CLI over the same typed API. **One query engine and no SQL**, so the typed commands are
the whole surface and a question no typed answer covers is reported as a gap rather than answered with
a query you invented. `runwatch query failures` lists only runs that did not complete successfully.

It listens on OTLP because that is what the agent already speaks — the transport is the input, not
the point. Reads of Etti's canonical store go through Etti's own bounded `etti inspect` protocol;
runwatch never opens that file.

Etti finds it automatically through an advertisement file, so no configuration is needed, and Etti
keeps working with runwatch absent, stopped or full.

- Data: `~/.local/share/runwatch` (28-day retention plus a disk bound; 0600 token, 0700 directory)
- Delete everything: remove that directory. `brew uninstall` does not.
- Start it yourself: `runwatch serve`. There is no background service.
- `runwatch version` (also `--version`, `-V`) prints `runwatch 0.2.0`.

## The content lane is opt-in, and it stores content

Operational records hold phases, timings, outcomes and counts — never prompts or output. Content is a
**separate, derived lane** that is off unless you grant it:

```bash
runwatch serve --etti-inspector /abs/path/etti --etti-state ~/.local/share/etti/instances/<name> \
               --allow-content <name>
```

With a grant, prompts, model output, tool arguments and results, and reasoning are pulled through
`etti inspect` and stored locally, so the run pages can show what was said and done. Without a grant
nothing is pulled. The lane is a rebuildable copy, not a second authority; `runwatch content delete
--run <id> | --all` is the delete path, and deleting cannot recall content already handed to an agent.
Anyone with local access to the store can read it, reasoning included — this is trusted same-UID
development, not a sandbox.

## Platforms

macOS arm64 and Linux x86_64 (static musl, no glibc floor). Each release archive is target-specific
because SQLite is compiled in; there is no universal binary.

0.2.0 archives, built from tag `v0.2.0` (`9c7c4ba`) in one detached checkout:

| target | archive | bytes | sha256 |
|---|---|---|---|
| macOS arm64 | `runwatch-0.2.0-9c7c4ba950e4-macos-arm64.tar.gz` | 2,597,657 | `d4cd395d84ca1ffd74e3222b888f7df1f3667df45dc75aa345a9c61237c6261e` |
| Linux x86_64 (static musl) | `runwatch-0.2.0-9c7c4ba950e4-linux-amd64.tar.gz` | 2,556,577 | `3100c6fe7723552790d2376f18d96c5910de18035dc5bc0b0f1b2d7bfee7608c` |

The formula's version, archive names and SHA-256 digests are always the built ones, generated from
the project's `packaging/` directory and checked after upload — no digest is ever hand-edited. The
caveat prose may be corrected after render without touching the archives; the archives behind these
digests are exactly the bytes that were built and run-verified.
