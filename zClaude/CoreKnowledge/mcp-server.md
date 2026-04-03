# Roblox MCP Server — Research & Setup Guide

## Overview

MCP (Model Context Protocol) servers let AI assistants (Claude Code, Cursor, etc.) interact directly with a live Roblox Studio session. Instead of writing scripts that run on Play, the AI executes commands in Edit mode — terrain changes, part placement, lighting tweaks are immediate and persistent.

## Available Options (as of April 2026)

### Option 1: Roblox Built-in MCP Server (Recommended)

Roblox has shifted engineering to a **built-in MCP server that ships with Studio**. This is now the official approach.

**How to enable:**
1. Open Roblox Studio
2. Open the Assistant widget
3. Click the "..." menu → "Manage MCP Servers"
4. Follow the setup guide to connect Claude Code or Cursor

**Tools provided:**
| Tool | What it does |
|------|-------------|
| `run_code` | Execute Luau in Studio's command context — the core tool. Anything you can do in the command bar, you can do here. |
| `insert_model` | Add Creator Store models to workspace |
| `get_console_output` | Read Studio console/output logs |
| `start_stop_play` | Toggle play/server modes |
| `run_script_in_play_mode` | Execute scripts with auto-stop and structured results |
| `get_studio_mode` | Check if Studio is in Edit, Play, or Run mode |
| `list_roblox_studios` | Find connected Studio instances |
| `set_active_studio` | Target a specific Studio instance |
| `user_mouse_input` | Simulate mouse clicks/movements during playtest |
| `user_keyboard_input` | Simulate keyboard presses during playtest |
| `character_navigation` | Move character via pathfinding during playtest |

**Key advantage:** Tools stay in sync with Studio automatically. No version mismatches.

**Source:** [Roblox/studio-rust-mcp-server](https://github.com/Roblox/studio-rust-mcp-server) (reference implementation, now superseded by built-in)

### Option 2: Weppy Roblox MCP (Community — Feature-rich)

[hope1026/weppy-roblox-mcp](https://github.com/hope1026/weppy-roblox-mcp) — Most feature-rich community option. 21 tools, 140+ actions.

**Install:**
```bash
curl -fsSL https://raw.githubusercontent.com/hope1026/weppy-roblox-mcp/main/install.sh | bash
```

**Extra capabilities beyond the official server:**
- Instance search, create, edit, property management
- Procedural terrain generation (Pro feature)
- Lighting and atmosphere control
- Camera positioning
- Creator Store asset search and insertion
- Tweening and effects
- Audio and animations (Pro)
- Bidirectional sync with local project files
- Web dashboard for monitoring
- VS Code Explorer extension showing instance tree

**Limitation:** AGPL-3.0 license. Some features are "Pro" (paid).

### Option 3: boshyxd/robloxstudio-mcp (Community — Actively maintained)

[boshyxd/robloxstudio-mcp](https://github.com/boshyxd/robloxstudio-mcp) — 51 tools for AI-powered game development.

## Architecture

All MCP servers for Roblox follow this pattern:

```
Claude Code / Cursor  <--MCP (stdio)--> MCP Server (local process) <--HTTP--> Roblox Studio Plugin
```

- **MCP Server**: Local process (Rust or Node.js) exposing tools via MCP protocol
- **Studio Plugin**: Polls the MCP server for pending commands, executes them, returns results
- **Communication**: HTTP on localhost (typically port 3000 or 3002)
- **Latency**: ~0.5-1s per round trip due to polling

## The Key Insight: `run_code` is Everything

The `run_code` tool executes arbitrary Luau in Studio's Edit mode context. This means:

- `workspace.Terrain:FillBlock(...)` — direct terrain manipulation
- `Instance.new("Part")` — create objects
- `game.Lighting.ClockTime = 14` — change lighting
- `workspace.Terrain:Clear()` — clear terrain

**Anything you can type in Studio's command bar, `run_code` can execute.**

The other tools (insert_model, get_console_output, etc.) are convenience wrappers for common operations.

## How This Changes Our Workflow

### Before (Rojo-only)
```
Edit TerrainGeneratorService.luau → Rojo syncs → Hit Play → Terrain generates → Stop → Repeat
```

### After (MCP + Rojo)
```
Tell Claude "make the pond deeper" → Claude calls run_code → Terrain changes immediately in Edit mode → Visible in viewport → Persists in place file
```

### Complementary Use
| Task | Use |
|------|-----|
| Game logic, services, controllers | Rojo (version controlled Luau files) |
| Terrain generation/iteration | MCP (direct manipulation, immediate feedback) |
| Lighting/atmosphere tweaks | MCP (immediate visual feedback) |
| Part placement, structures | MCP (see it immediately) |
| Module scripts, shared code | Rojo (needs version control) |

## Best Practices

1. **Use `ChangeHistoryService`** — Wrap MCP operations in waypoints for Ctrl+Z undo:
   ```lua
   local CHS = game:GetService("ChangeHistoryService")
   CHS:SetWaypoint("Before terrain change")
   -- do terrain work
   CHS:SetWaypoint("After terrain change")
   ```

2. **Break large operations into chunks** — Large terrain fills can freeze Studio. Batch into smaller calls.

3. **Save frequently** — MCP modifies the place file directly. Save before big operations.

4. **Read before write** — Query current state before modifying to avoid destroying work.

5. **Keep Rojo for code** — MCP is for live manipulation. Game logic, services, and controllers stay as Rojo-synced files.

6. **Edit mode only** — MCP commands execute in Edit mode context. Enter Play mode for testing separately.

## Context Management (CRITICAL)

### The Screenshot Problem
Each `screen_capture` returns a base64 image that stays in context permanently. Measured impact:
- 18 screenshots = ~1.7 MB = 64% of session file
- A 1000x1000 screenshot costs ~1,334 tokens
- Resuming a screenshot-heavy session consumed 17% of a Max plan's 5-hour budget in 5 API calls

### Rules
1. **Use `screen_capture` only after major milestones** — never after small changes
2. **Verify programmatically first** — `search_game_tree`, `inspect_instance` cost almost nothing
3. **Use `/compact` aggressively** at ~60% context, especially after screenshots
4. **Start fresh sessions** (`/clear`) when switching between terrain iteration and code writing
5. **Keep `execute_luau` outputs small** — large outputs hang for 30s+ then crash. Many small calls > one giant call
6. **For large terrain ops**: Put logic in a ModuleScript, invoke via tiny `require()` call through MCP

### Known Bugs
- `execute_luau` hangs on large outputs (30s timeout + exponential backoff)
- Claude Desktop has 1MB limit on MCP tool results
- `get_studio_mode` returns wrong value when Play started manually
- AI tends to generate `Players.LocalPlayer` in server context — always review

## Limitations

- Studio must be open and connected
- No file upload (meshes, images) — reference existing assets by ID only
- Poll-based latency (~0.5-1s per round trip)
- `WriteVoxels` limited to 64x64x64 voxels per call — chunk large terrain
- No hard script size limit, but keep `execute_luau` calls under a few hundred lines
- ~1-2 operations per second max throughput (poll architecture)
- Single Studio session assumed — port conflicts with multiple Studios
- Error stack traces can be truncated

## Setup for Claude Code

For the built-in server, add to `.mcp.json` in the project root:

```json
{
  "mcpServers": {
    "roblox-studio": {
      "command": "/path/to/roblox-studio-mcp-server",
      "args": ["--stdio"]
    }
  }
}
```

For Weppy, use:
```json
{
  "mcpServers": {
    "roblox-studio": {
      "command": "npx",
      "args": ["-y", "@weppy/roblox-mcp"]
    }
  }
}
```

Exact paths depend on installation method. See each project's README for details.
