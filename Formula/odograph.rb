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
  version "0.1.3"
  license :cannot_represent

  # DuckDB is statically linked, so every archive is target-specific: no universal binary. The Linux
  # build is static musl, so it carries no glibc floor and runs on any modern distribution.
  on_macos do
    depends_on arch: :arm64
    depends_on macos: :sonoma
    on_arm do
      url "https://github.com/open-assistants-lab/homebrew-telemetry/releases/download/v0.1.3/odograph-0.1.3-01a3503065b8-macos-arm64.tar.gz"
      sha256 "a76fc9b880458c6e43df1193494e942b44f455b8c167f04414ec9a0cc1459700"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/open-assistants-lab/homebrew-telemetry/releases/download/v0.1.3/odograph-0.1.3-01a3503065b8-linux-amd64.tar.gz"
      sha256 "cc26224908ede4b5699020c4edd3d96a796ccb4650eece7bcfa31031ffd940b0"
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
