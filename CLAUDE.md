# CLAUDE.md

## What is this project?

Vibe Island is a native macOS companion app for AI coding agents. It sits in the notch/top-bar area and monitors local agent sessions, surfaces permission requests, answers questions, and provides "jump back" to the correct terminal context. Local-first, no server dependency.

## References

- **Target product**: https://vibeisland.app/ — the commercial product we are building toward feature parity with
- **Reference OSS repo**: https://github.com/farouqaldori/claude-island — open-source implementation we can study for design patterns and ideas

## Architecture

Three layers:

1. **VibeIslandApp** — SwiftUI + AppKit shell. Menu bar extra, overlay panel (notch/top-bar), and control center window. Entry point: `VibeIslandApp.swift` with `AppModel` as the central `@Observable` state owner.
2. **VibeIslandCore** — Shared library. Models (`AgentSession`, `AgentEvent`, `SessionState`), bridge transport (Unix socket IPC with JSON line protocol), Codex hook models, hook installer, rollout watcher/discovery, and session persistence.
3. **VibeIslandHooks** — Lightweight CLI executable invoked by Codex hooks. Reads hook payload from stdin, forwards to app bridge via Unix socket, writes blocking JSON to stdout only when island denies a `PreToolUse`.
4. **VibeIslandSetup** — Installer CLI for managing `~/.codex/config.toml` and `hooks.json`.

## Key data flow

Codex → hooks.json → VibeIslandHooks (stdin/stdout) → Unix socket (`/tmp/vibe-island-<uid>.sock`) → DemoBridgeServer → AppModel → UI

On launch: restore cached sessions → discover recent rollout JSONL files → start live bridge → tail transcript files for enriched state.

## Supported scope (narrow by design)

- **Agents**: Codex (fully wired), Claude Code (in scope, no adapter yet)
- **Terminals**: Terminal.app, Ghostty
- Do NOT expand scope unless explicitly asked

## Build & test

```bash
swift build
swift test
swift run VibeIslandApp        # run the app
swift build -c release --product VibeIslandHooks  # build hook binary
```

Open `Package.swift` in Xcode for the app target. Requires macOS 14+, Swift 6.2.

## Conventions

- Conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`, `chore:`
- Each round of changes should be a single focused commit
- Prefer small end-to-end slices over speculative scaffolding
- Native macOS APIs over cross-platform abstractions
- Hooks fail open — if app/bridge unavailable, Codex keeps running unchanged
- The `SessionState.apply(_:)` reducer is the single source of truth for session mutations
- Bridge protocol uses newline-delimited JSON envelopes (`BridgeCodec`)
- All models are `Sendable` and `Codable`

## Important files

- `Sources/VibeIslandApp/AppModel.swift` — Central app state, session management, bridge lifecycle
- `Sources/VibeIslandCore/SessionState.swift` — Pure state reducer for agent sessions
- `Sources/VibeIslandCore/AgentSession.swift` — Core session model and related types
- `Sources/VibeIslandCore/AgentEvent.swift` — Event enum driving all state transitions
- `Sources/VibeIslandCore/BridgeTransport.swift` — Unix socket protocol, codec, envelope types
- `Sources/VibeIslandCore/CodexHooks.swift` — Codex hook payload model and terminal detection
- `Sources/VibeIslandHooks/main.swift` — Hook CLI entry point
- `Sources/VibeIslandApp/OverlayPanelController.swift` — Notch/top-bar overlay window
- `docs/product.md` — Product scope and MVP boundary
- `docs/architecture.md` — System design and engineering decisions
- `AGENTS.md` — Working agreement for agent workflow
