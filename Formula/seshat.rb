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
  version "0.3.2"
  license "MIT"

  # Release archive filenames embed the tag after the target triple
  # (see .github/workflows/release.yml — `seshat-<TARGET>-v<VERSION>.tar.gz`).
  # Intel-Mac (x86_64-apple-darwin) is intentionally absent from the build
  # matrix because the `ort` crate (ONNX Runtime, via fastembed) no longer
  # ships prebuilt binaries for that target.
  on_macos do
    on_arm do
      url "https://github.com/KSDaemon/seshat/releases/download/v#{version}/seshat-aarch64-apple-darwin-v#{version}.tar.gz"
      sha256 "bac9b8d947de091b81ef535b03736cc9a2948d2846f1e9285dd39313657556e6"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/KSDaemon/seshat/releases/download/v#{version}/seshat-aarch64-unknown-linux-gnu-v#{version}.tar.gz"
      sha256 "190156a6ff35f4eccea4abe0ab8be1c0916cf64a3c36910e2dc3da2a4c53d016"
    end
    on_intel do
      url "https://github.com/KSDaemon/seshat/releases/download/v#{version}/seshat-x86_64-unknown-linux-gnu-v#{version}.tar.gz"
      sha256 "1e935d2d49259da1dfaf6988a491771686fad0bbc3848387eff7e8bdaa0fcf36"
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
