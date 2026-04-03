# Roblox Claude Bootstrap

A production-ready Roblox game project template designed for AI-assisted development with Claude Code or Cursor.

Includes a modern development stack, comprehensive Roblox reference documentation, MCP integration guides, and battle-tested conventions learned from building real games.

## What's Included

### Stack
| Tool | Purpose |
|------|---------|
| [Luau](https://luau-lang.org/) | Roblox's typed scripting language |
| [Rojo](https://rojo.space/) | Syncs filesystem code with Roblox Studio |
| [Knit](https://sleitnick.github.io/Knit/) | Lightweight game framework (Services/Controllers) |
| [Wally](https://wally.run/) | Package manager |
| [Rokit](https://github.com/rojo-rbx/rokit) | Toolchain manager |
| [Selene](https://kampfkarren.github.io/selene/) | Linter |
| [StyLua](https://github.com/JohnnyMorganz/StyLua) | Formatter |

### Knowledge Base (`zClaude/CoreKnowledge/`)
Reference docs covering every major Roblox development topic:
- Roblox architecture & DataModel
- Luau language (syntax, types, performance)
- Networking & security (RemoteEvents, validation, rate limiting)
- Frameworks & patterns (Knit, ProfileService, Matter ECS)
- Data persistence (DataStore, MemoryStore, session locking)
- UI development (React-Lua, Fusion, traditional)
- Tooling ecosystem (Rokit, Rojo, Wally, Selene, testing)
- Project structure & file naming
- Performance (pitfalls, MicroProfiler, metrics)
- MCP server setup & context management

### Claude Integration
- `CLAUDE.md` with comprehensive coding conventions, security rules, and MCP usage guidelines
- Terrain generation best practices (hard-won lessons about the Roblox terrain engine)
- Screenshot/context management rules to prevent session bloat

## Prerequisites

- [Roblox Studio](https://www.roblox.com/create)
- Git
- Claude Code, Cursor, or another MCP-compatible AI tool

## Setup

```sh
bin/setup
```

This installs Rokit, Rojo, Wally, Selene, StyLua, all Wally packages, and the Rojo plugin for Studio.

## Development

Start the Rojo sync server:

```sh
bin/dev
```

Open Roblox Studio, connect via the Rojo plugin.

### With MCP (Recommended)

Connect Claude Code or Cursor to Roblox Studio's built-in MCP server for direct manipulation of terrain, lighting, parts, and more — no Play button needed.

See `zClaude/CoreKnowledge/mcp-server.md` for setup instructions.

## Project Structure

```
src/
  server/                  Server-side code (ServerScriptService)
    init.server.luau       Server entry point — boots Knit
    Services/              Game services
  client/                  Client-side code (StarterPlayerScripts)
    init.client.luau       Client entry point — boots Knit
    Controllers/           Game controllers
  shared/                  Shared modules (ReplicatedStorage)
bin/
  setup                    One-time project setup
  dev                      Start Rojo dev server
zClaude/
  CoreKnowledge/           Roblox development reference library
  README.md                Knowledge base index
```

## Coding Conventions

See `CLAUDE.md` for the full list. Key highlights:
- `--!strict` on every file
- camelCase variables, PascalCase modules, UPPER_SNAKE_CASE constants
- `task.wait()` / `task.spawn()` — never deprecated equivalents
- Set Instance parent last
- Server validates all client input

## Linting and Formatting

```sh
selene src/
stylua --check src/
stylua src/          # auto-format
```
