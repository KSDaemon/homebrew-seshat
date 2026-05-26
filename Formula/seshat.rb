# Homebrew formula for Seshat.
#
# This file is the source of truth maintained inside the seshat repo.
# The release pipeline (`.github/workflows/homebrew-bump.yml`) copies
# this template into the public tap repo (`KSDaemon/homebrew-seshat`)
# on each tag push, substituting the version and per-platform SHA256
# placeholders below.
#
# End users install via:
#   brew tap KSDaemon/seshat
#   brew install seshat
#
# Local install for testing (without the tap):
#   brew install --build-from-source ./homebrew/seshat.rb

class Seshat < Formula
  desc "Operating manual for your codebase, written for AI agents (MCP server)"
  homepage "https://github.com/KSDaemon/seshat"
  version "0.5.0"
  license "MIT"

  # Release archive filenames embed the tag after the target triple
  # (see .github/workflows/release.yml — `seshat-<TARGET>-v<VERSION>.tar.gz`).
  # Intel-Mac (x86_64-apple-darwin) is intentionally absent from the build
  # matrix because the `ort` crate (ONNX Runtime, via fastembed) no longer
  # ships prebuilt binaries for that target.
  on_macos do
    on_arm do
      url "https://github.com/KSDaemon/seshat/releases/download/v#{version}/seshat-aarch64-apple-darwin-v#{version}.tar.gz"
      sha256 "0a5da50214446b94a7e54bfa51a02651f6bcdf3b17651f3f79199b9b32611b10"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/KSDaemon/seshat/releases/download/v#{version}/seshat-aarch64-unknown-linux-gnu-v#{version}.tar.gz"
      sha256 "55285404ab91efff0ef746a5501b3e4d6ffb6e76c27b26db84b3a6f496868683"
    end
    on_intel do
      url "https://github.com/KSDaemon/seshat/releases/download/v#{version}/seshat-x86_64-unknown-linux-gnu-v#{version}.tar.gz"
      sha256 "1c3e02d34c2c9ff151b0d4571fd97556367f106abf60bf76b2c2e7c47258c570"
    end
  end

  # Standard upstream-version tracking so `brew livecheck seshat` works
  # and `brew audit --strict` doesn't flag a missing block. Matches
  # GitHub release tags shaped `v<MAJOR>.<MINOR>.<PATCH>[-<pre>]`,
  # exactly the pattern enforced in homebrew-bump.yml.
  livecheck do
    url :stable
    strategy :github_latest
    regex(/^v?(\d+(?:\.\d+)+(?:-[A-Za-z0-9.-]+)?)$/i)
  end

  def install
    bin.install "seshat"

    # Pre-generated completion scripts ship inside the release tarball
    # under completions/. We hand them to the standard Homebrew helpers
    # so brew installs them into the right path for each shell.
    #
    # PowerShell and Elvish scripts are also bundled in the tarball
    # (`_seshat.ps1`, `seshat.elv`) but Homebrew has no per-shell helper
    # for them; users on those shells should grab the standalone
    # `seshat-completions.tar.gz` from the GitHub Release directly.
    bash_completion.install "completions/seshat.bash" => "seshat"
    zsh_completion.install  "completions/_seshat"
    fish_completion.install "completions/seshat.fish"
  end

  test do
    # `brew test` runs in a sandboxed environment without writing back
    # to the user's HOME. seshat caches version-check results under
    # `dirs::data_dir()` (i.e. $HOME) on first run, so redirect HOME
    # at test-block scope to keep the test hermetic.
    ENV["HOME"] = testpath

    # `--version` should print the embedded version. The build-time
    # suffix `(<git-hash>)` makes an exact equality check fragile,
    # but matching against `version.to_s` confirms we installed the
    # *right* artifact (vs. the previous `assert_match "seshat"` which
    # would pass for literally any binary called `seshat`).
    assert_match version.to_s, shell_output("#{bin}/seshat --version")

    # `completions bash` must produce a parseable bash function.
    output = shell_output("#{bin}/seshat completions bash")
    assert_match "_seshat()", output
  end
end
