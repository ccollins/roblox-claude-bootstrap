# Roblox Game Project

## First Thing Every Conversation

Read `zClaude/README.md` to understand the project structure, then consult files in `zClaude/CoreKnowledge/` as needed for the task at hand.

## Bootstrap Repo

This project was bootstrapped from https://github.com/ccollins/roblox-claude-bootstrap. When you discover new **core Roblox knowledge** (not game-specific), consider whether it should be pushed upstream to the bootstrap repo so future projects benefit. This includes: CLAUDE.md convention changes, new CoreKnowledge docs, tooling improvements, MCP best practices, and bin/ script enhancements.

## Stack
- **Language**: Luau (strict type annotations)
- **Sync**: Rojo (filesystem <-> Roblox Studio)
- **Packages**: Wally
- **Framework**: Knit (Services on server, Controllers on client)
- **Linter**: Selene (roblox std)
- **Formatter**: StyLua (tabs, 120 col width)
- **Editor**: Cursor

## Project Structure
```
src/server/          -- ServerScriptService (Services)
src/client/          -- StarterPlayerScripts (Controllers)
src/shared/          -- ReplicatedStorage (shared modules)
```

## Language & Runtime
- All game code is **Luau** (not Lua), using `.luau` extension
- Use `--!strict` at the top of every new file
- Use `task.spawn` / `task.wait` / `task.defer` — never legacy `spawn` / `wait` / `delay`
- Always use `local` — globals disable Luau optimizations
- Define `export type` for all public module interfaces

## Coding Conventions
- **camelCase** for variables and functions
- **PascalCase** for modules, classes, services, controllers, and Roblox API calls
- **UPPER_SNAKE_CASE** for constants
- **Underscore prefix** for private methods (`_calculateScore`)
- Use `game:GetService("ServiceName")` not direct property access
- Use guard clauses (early returns) over nested conditionals
- Type-annotate function parameters and return values
- Set Instance parent **last** after setting all properties
- Prefer `Clone()` over `Instance.new()` when possible
- Disconnect event connections when no longer needed; use `:Once()` for single-fire
- Use ModuleScripts for reusable logic — keep scripts DRY
- No magic numbers — use named constants

## Security
- **Server code** (`src/server/`) is authoritative — never trust client input
- **Client code** (`src/client/`) handles input, UI, local effects only
- Every RemoteEvent handler on the server **must** validate argument types, ranges, and sanity
- Never send prices, damage values, or currency from client to server — look up server-side

## Knit Patterns
- Server logic goes in Services (`src/server/Services/`)
- Client logic goes in Controllers (`src/client/Controllers/`)
- Shared utilities/types go in `src/shared/`
- Services expose client endpoints via `self.Client` table
- Require services/controllers in the init scripts, then call `Knit.Start()`

## File Naming
- `init.server.luau` — server entry script
- `init.client.luau` — client entry script
- `*.luau` — module scripts (default)
- `*.server.luau` — server scripts
- `*.client.luau` — client scripts
- `*.spec.luau` — test files (excluded from Rojo build)

## MCP (Roblox Studio Direct Manipulation)

### When to use MCP vs Rojo
- **MCP (`execute_luau`)**: Terrain, lighting, part placement, visual iteration — anything you want to see immediately in Edit mode
- **Rojo**: Game logic, services, controllers, modules — anything that needs version control

### General Rules
- **Roblox Studio updates frequently.** Never assume a property, feature, or UI element exists based on docs or training data. Use `inspect_instance` or `search_game_tree` to verify before suggesting manual steps. Example: `Lighting.Technology` was replaced by Unified Lighting — the property no longer exists in the UI.
- **`execute_luau` cannot write some properties** (e.g. `Lighting.Technology`) due to engine capability restrictions. When a property fails, note it and find an alternative.

### Critical Rules for MCP Usage
- **`screen_capture` is EXPENSIVE** — each screenshot costs ~1,334 tokens and stays in context permanently. Use sparingly, only after major milestones. NEVER take screenshots after every small change.
- **Verify changes programmatically** — use `search_game_tree` and `inspect_instance` instead of screenshots whenever possible.
- **Keep `execute_luau` outputs SMALL** — large outputs crash the connection (30s timeout). Prefer many small calls over one giant call. Never request "full tree" dumps.
- **For large terrain operations**: Write the generator as a standalone `.luau` script or ModuleScript, then execute via MCP with a small call.
- **Wrap MCP operations in undo waypoints**:
  ```lua
  local CHS = game:GetService("ChangeHistoryService")
  CHS:SetWaypoint("Before change")
  -- do work
  CHS:SetWaypoint("After change")
  ```
- **Use `/compact` aggressively** during MCP sessions, especially after any `screen_capture` calls.
- **Save the place file before big operations** — MCP modifies the place directly.
- **Never leave artifacts only in Studio** — always have a reproducible `.luau` script in `bin/` that generates the same result. Ad-hoc MCP calls create fragile state that can't be reproduced when things go wrong. Use `ReplaceMaterial` to change surface materials without geometry changes.

### Reproducible World Generation
All programmatic artifacts (terrain, lighting, structures, etc.) must have corresponding `.luau` scripts in `bin/` that can regenerate them from scratch. Scripts should:
- Clear existing state before generating (idempotent)
- Use deterministic RNG seeds (`Random.new(42)`) for identical output every run
- Be executable via MCP `execute_luau` or Studio's Command Bar
- Be version-controlled in git — the script is the source of truth, not the place file
- **CRITICAL: Update generation scripts immediately after EVERY MCP change.** Never batch up MCP terrain/asset fixes without updating the corresponding script. If you modify terrain, place assets, or adjust positions via MCP `execute_luau`, update `bin/terrain/generate.luau` (or the relevant script) in the same step. The script must always reproduce the current world state. Failing to do this causes the script and Studio to drift apart, making "regenerate world" produce a different result than what's in the place file.

Organize scripts by system:
```
bin/
  regenerate-world       -- runs all generation scripts in order
  terrain/
    generate.luau        -- terrain, structures, vegetation
    lighting.luau        -- lighting, atmosphere, post-processing
    regenerate           -- runs terrain scripts only
  wildlife/              -- (future) ambient creature spawning
```

Define regeneration commands in CLAUDE.md so the AI knows what to run:
- **"regenerate terrain"** → execute terrain scripts via MCP
- **"regenerate world"** → execute ALL scripts in order via MCP
- Add new systems to the regeneration list as they are built

### Terrain Best Practices (Roblox Engine)
- Water `FillCylinder` REPLACES solid terrain — to create varying depth, fill water first, then place solid terrain on top to displace it
- Always destroy the default Baseplate and SpawnLocation in terrain generation
- Use `FillCylinder`/`FillBall`/`FillBlock` for terrain — avoid `WriteVoxels` for water (known engine bugs with gaps)
- Set parent last on all Instances
- Use deterministic RNG seeds (`Random.new(42)`) for reproducible world generation
- Ground layers must be thick enough (12+ studs) to prevent showing through
