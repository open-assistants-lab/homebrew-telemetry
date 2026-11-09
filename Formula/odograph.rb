# Homebrew formula template for odograph.
#
# `packaging/build-release.sh` renders this into `Formula/odograph.rb`, substituting the version,
# the archive name and its digest. It is deliberately a template: a committed formula with a
# guessed digest would either fail to install or install the wrong bytes.
#
# The tap is expected to be `open-assistants-lab/telemetry`, matching the sibling
# `open-assistants-lab/coding` tap that carries etti.
class Odograph < Formula
  desc "Local operational diagnostics for coding agents"
  homepage "https://github.com/open-assistants-lab/homebrew-telemetry"
  url "https://github.com/open-assistants-lab/homebrew-telemetry/releases/download/v0.1.1/odograph-0.1.1-62c97544b96d-macos-arm64.tar.gz"
  version "0.1.1"
  sha256 "fef06cb43b3f79b21093d909f0d64e2f9c84d1e21fe85b11c29d637253e2d86c"
  license :cannot_represent

  # DuckDB is statically linked, so the archive is arch-specific: there is no universal binary.
  depends_on arch: :arm64
  depends_on macos: :sonoma

  def install
    bin.install "odograph"
    doc.install "README.txt", "NOTICE.txt"
  end

  # No `service` block on purpose. `brew services start odograph` would run an always-on daemon,
  # which is a different product from a tool you start when you want to look at something. Start
  # it in a terminal with `odograph serve` and stop it with ctrl-c.
  def caveats
    <<~EOS
      Start it yourself; there is no background service:

          odograph serve

      It prints a one-time URL. Open it once to exchange the token for a cookie.
      Ingest on /v1/* is open on loopback; everything that returns stored data needs the token.

      Etti finds odograph automatically through its advertisement file, so no flag or
      configuration is needed. With odograph stopped, Etti simply sends nothing.

      Storage: ~/.local/share/odograph (28-day retention, plus a disk bound).
      `brew uninstall` does not delete it; remove that directory to delete everything.

      Artifact metadata read-through needs Etti's state directory:

          odograph serve --etti-state ~/.local/share/etti/instances/<instance>

      No account, no egress, no telemetry of its own. Not a sandbox: it runs as you.
    EOS
  end

  test do
    # Offline and isolated: a disposable data directory, no daemon, no network, no live store.
    ENV["HOME"] = testpath.to_s
    ENV["XDG_DATA_HOME"] = (testpath / "data").to_s
    system bin / "odograph", "help"

    (testpath / "data").mkpath
    system bin / "odograph", "sweep", "--data-dir", (testpath / "data").to_s
  end
end
