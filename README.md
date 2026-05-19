# homebrew-seshat

Official Homebrew tap for [Seshat](https://github.com/KSDaemon/seshat) — the
operating manual for your codebase, written for AI agents (MCP server).

## Install

```bash
brew tap KSDaemon/seshat
brew install seshat
```

## How this tap is updated

The `Formula/seshat.rb` file in this repository is regenerated automatically
on each upstream release by the
[`homebrew-bump`](https://github.com/KSDaemon/seshat/blob/main/.github/workflows/homebrew-bump.yml)
workflow in the main `seshat` repo. The source-of-truth template lives at
[`homebrew/seshat.rb`](https://github.com/KSDaemon/seshat/blob/main/homebrew/seshat.rb)
upstream — please open formula PRs there, not here.

## Supported platforms

Built and tested in CI on:

- macOS arm64 (Apple Silicon)
- Linux x86_64
- Linux arm64

Intel Mac (`x86_64-apple-darwin`) is not currently shipped — the `ort` crate
(ONNX Runtime, via fastembed) no longer ships prebuilt binaries for that
target. Users on Intel Macs can build from source via `cargo install seshat-bin`.
