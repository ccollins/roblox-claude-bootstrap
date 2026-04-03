# Tooling Ecosystem

## StudioMCP (Roblox Studio MCP Server)

Built into Roblox Studio. Gives Claude Code direct access to the running Studio instance via Model Context Protocol.

**Setup:** Configured in project `.mcp.json`:
```json
{
  "mcpServers": {
    "Roblox_Studio": {
      "command": "/Applications/RobloxStudio.app/Contents/MacOS/StudioMCP",
      "args": []
    }
  }
}
```

**Capabilities:**

| Category | Tools | Purpose |
|----------|-------|---------|
| **Explore** | `search_game_tree`, `inspect_instance` | Browse DataModel hierarchy, read properties/attributes |
| **Scripts** | `script_read`, `script_grep`, `script_search`, `multi_edit` | Read, search, edit, and create scripts directly in Studio |
| **Execute** | `execute_luau` | Run arbitrary Luau in Studio (create parts, modify instances, etc.) |
| **Assets** | `insert_from_creator_store`, `generate_mesh`, `generate_material` | Pull marketplace models, AI-generate meshes and materials |
| **Playtest** | `start_stop_play`, `get_console_output`, `character_navigation` | Start/stop play, read output log, move character |
| **Input** | `user_keyboard_input`, `user_mouse_input` | Simulate player input during playtesting |
| **Visual** | `screen_capture` | Screenshot the Studio viewport |
| **Session** | `list_roblox_studios`, `set_active_studio` | Manage multiple Studio windows |

**How it complements Rojo:** Rojo syncs Luau source files from disk into Studio. StudioMCP lets Claude Code interact with Studio directly — building the 3D world (placing parts, models, terrain via `execute_luau`), pulling marketplace assets, playtesting, and reading console output. Use both together: **Rojo for versioned source code, StudioMCP for live Studio interaction and world-building.**

## Rokit (Toolchain Manager) — Replaces Aftman/Foreman

Community standard as of 2025. Installs and manages Roblox dev tools.

```bash
# Install Rokit
curl -sSf https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.sh | bash

# Add tools
rokit add rojo-rbx/rojo
rokit add UpliftGames/wally
rokit add JohnnyMorganz/StyLua
rokit add Kampfkarren/selene
rokit add seaofvoices/darklua
```

Creates `rokit.toml` in project root, pinning versions.

## Rojo (File Sync)

Bridges filesystem ↔ Roblox Studio. Enables Git, VS Code, and standard dev workflows.

**Usage:** `rojo serve` (live sync) or `rojo build -o game.rbxl` (build place file)

### File Naming Conventions

- `init.server.luau` — Script (runs on server)
- `init.client.luau` — LocalScript (runs on client)
- `init.luau` — ModuleScript (folder's "index")
- `MyModule.luau` — ModuleScript named "MyModule"
- `Main.server.luau` — Script named "Main"
- `PlayerSetup.client.luau` — LocalScript named "PlayerSetup"
- `*.spec.luau` — test files (exclude via `globIgnorePaths`)

## Wally (Package Manager)

Roblox's npm equivalent. Uses `wally.toml`:

```toml
[package]
name = "yourusername/mygame"
version = "0.1.0"
registry = "https://github.com/UpliftGames/wally-index"
realm = "shared"

[dependencies]
Knit = "sleitnick/knit@1.6.0"
Signal = "sleitnick/signal@2.0.0"
Promise = "evaera/promise@4.0.0"
ProfileService = "madstudioroblox/profileservice@1.3.0"
React = "jsdotlua/react@17.1.0"
ReactRoblox = "jsdotlua/react-roblox@17.1.0"

[server-dependencies]
# Server-only packages

[dev-dependencies]
TestEZ = "roblox/testez@0.4.1"
```

Run `wally install` → creates `Packages/` folder. Map in Rojo project.

## Selene (Linter)

Static analysis for Luau. Catches bugs, unused variables, shadowing, type mismatches.

Config: `selene.toml` with `std = "roblox"`

## StyLua (Formatter)

Opinionated code formatter. Config: `stylua.toml`

```toml
column_width = 120
line_endings = "Unix"
indent_type = "Tabs"
indent_width = 4
quote_style = "AutoPreferDouble"
```

## Darklua (Code Transformer)

Processes/transforms Luau code:
- Bundling multiple modules into single file
- Minification
- Dead code elimination
- Require path conversion (filesystem → Roblox instance)

Config: `.darklua.json`. Essential for CI/CD pipelines.

## Testing

### TestEZ (BDD-style, widely adopted)

```lua
return function()
    describe("InventoryService", function()
        it("should add items", function()
            local inv = InventoryService.new()
            inv:addItem("Sword")
            expect(inv:hasItem("Sword")).to.equal(true)
        end)
    end)
end
```

### Jest-Lua (port of Jest 27.4.7)

More feature-rich: mocking, snapshots, better async. Wally: `jsdotlua/jest@3.6.1`
