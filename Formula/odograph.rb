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
  version "0.1.6"
  license :cannot_represent

  # SQLite is statically linked, so every archive is target-specific: no universal binary. The Linux
  # build is static musl, so it carries no glibc floor and runs on any modern distribution.
  on_macos do
    depends_on arch: :arm64
    depends_on macos: :sonoma
    on_arm do
      url "https://github.com/open-assistants-lab/homebrew-telemetry/releases/download/v0.1.6/odograph-0.1.6-435763a77a65-macos-arm64.tar.gz"
      sha256 "516300f6aa85d6384e82fac819992b21a1ad64f92b4796d1e9a5c6435d418c9d"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/open-assistants-lab/homebrew-telemetry/releases/download/v0.1.6/odograph-0.1.6-435763a77a65-linux-amd64.tar.gz"
      sha256 "c49ff50e15f4bcab9ea45c92c7671ad4098b865cf2de3dcdb3029ba142b8b628"
    end
  end

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

      Artifact metadata read-through needs Etti 0.1.12 or later and both flags — the bounded
      inspector, and the state directory it is allowed to read through that inspector:

          odograph serve --etti-inspector /abs/path/to/etti --etti-state ~/.local/share/etti/instances/<instance>

      Alone, --etti-state refuses at startup and names the missing flag.

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
