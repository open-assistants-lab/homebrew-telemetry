# Homebrew formula template for runwatch.
#
# `packaging/build-release.sh` renders this into `Formula/runwatch.rb`, substituting the version,
# the archive name and its digest. It is deliberately a template: a committed formula with a
# guessed digest would either fail to install or install the wrong bytes.
#
# The tap is expected to be `open-assistants-lab/telemetry`, matching the sibling
# `open-assistants-lab/coding` tap that carries etti.
class Runwatch < Formula
  desc "Local operational diagnostics for coding agents"
  homepage "https://github.com/open-assistants-lab/homebrew-telemetry"
  version "0.2.0"
  license "MIT"

  # SQLite is statically linked, so every archive is target-specific: no universal binary. The Linux
  # build is static musl, so it carries no glibc floor and runs on any modern distribution.
  on_macos do
    depends_on arch: :arm64
    depends_on macos: :sonoma
    on_arm do
      url "https://github.com/open-assistants-lab/homebrew-telemetry/releases/download/v0.2.0/runwatch-0.2.0-9c7c4ba950e4-macos-arm64.tar.gz"
      sha256 "d4cd395d84ca1ffd74e3222b888f7df1f3667df45dc75aa345a9c61237c6261e"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/open-assistants-lab/homebrew-telemetry/releases/download/v0.2.0/runwatch-0.2.0-9c7c4ba950e4-linux-amd64.tar.gz"
      sha256 "3100c6fe7723552790d2376f18d96c5910de18035dc5bc0b0f1b2d7bfee7608c"
    end
  end

  def install
    bin.install "runwatch"
    doc.install "README.txt", "NOTICE.txt"
  end

  # No `service` block on purpose. `brew services start runwatch` would run an always-on daemon,
  # which is a different product from a tool you start when you want to look at something. Start
  # it in a terminal with `runwatch serve` and stop it with ctrl-c.
  def caveats
    <<~EOS
      Start it yourself; there is no background service:

          runwatch serve

      It prints a one-time URL. Open it once to exchange the token for a cookie.
      Ingest on /v1/* is open on loopback; everything that returns stored data needs the token.

      Etti finds runwatch automatically through its advertisement file, so no flag or
      configuration is needed. With runwatch stopped, Etti simply sends nothing.

      Storage: ~/.local/share/runwatch (28-day retention, plus a disk bound).
      `brew uninstall` does not delete it; remove that directory to delete everything.

      Artifact metadata read-through needs Etti 0.1.12 or later and both flags — the bounded
      inspector, and the state directory it is allowed to read through that inspector:

          runwatch serve --etti-inspector /abs/path/to/etti --etti-state ~/.local/share/etti/instances/<instance>

      No account, no egress, no telemetry of its own. Not a sandbox: it runs as you.
    EOS
  end

  test do
    # Offline and isolated: a disposable data directory, no daemon, no network, no live store.
    ENV["HOME"] = testpath.to_s
    ENV["XDG_DATA_HOME"] = (testpath / "data").to_s
    system bin / "runwatch", "help"
    assert_match "runwatch 0.2.0", shell_output("#{bin}/runwatch --version")

    (testpath / "data").mkpath
    system bin / "runwatch", "sweep", "--data-dir", (testpath / "data").to_s
  end
end
