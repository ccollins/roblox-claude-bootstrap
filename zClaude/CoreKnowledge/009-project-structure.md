# Project Structure

## Professional Filesystem Layout

```
my-game/
  rokit.toml              -- Toolchain versions (rojo, wally, selene, stylua)
  default.project.json    -- Rojo project mapping
  wally.toml              -- Package dependencies
  wally.lock              -- Locked dependency versions
  selene.toml             -- Linter config
  stylua.toml             -- Formatter config
  .darklua.json           -- Code transformer config (if used)
  .gitignore
  Packages/               -- Wally-installed packages (gitignored)
  assets/
    Terrain.rbxm          -- Binary terrain data
    models/               -- .rbxm model files
  src/
    server/               -- Maps to ServerScriptService
      init.server.luau    -- Server bootstrap
      Services/
        GameService.luau
        DataService.luau
        CombatService.luau
        ShopService.luau
      Components/         -- Server-side components
    client/               -- Maps to StarterPlayerScripts
      init.client.luau    -- Client bootstrap
      Controllers/
        InputController.luau
        UIController.luau
        CameraController.luau
      Components/         -- Client-side components
    shared/               -- Maps to ReplicatedStorage
      Modules/
        Types.luau        -- Shared type definitions
        Constants.luau    -- Game constants
        ItemData.luau     -- Item definitions
      Remotes.luau        -- Remote event/function definitions
      Utils/
        TableUtil.luau
        MathUtil.luau
  tests/                  -- Test files
    server/
    client/
    shared/
```

## Naming Conventions

### Files (Rojo)

- `init.server.luau` → Script (server)
- `init.client.luau` → LocalScript (client)
- `init.luau` → ModuleScript (folder index)
- `MyModule.luau` → ModuleScript named "MyModule"
- `*.spec.luau` → test files

### Code

- **camelCase**: variables, parameters (`playerHealth`, `itemCount`)
- **PascalCase**: classes, services, modules, types (`InventoryService`, `WeaponConfig`)
- **UPPER_SNAKE_CASE**: constants (`MAX_HEALTH`, `DEFAULT_WALKSPEED`)
- **PascalCase methods**: `GameService:StartRound()`
- **Underscore prefix for private**: `GameService:_calculateScore()`

## Organizational Principles

1. **Modularity** — each module does one thing, break at ~300 lines
2. **Separation of concerns** — server logic never in client scripts and vice versa
3. **Single entry point** — one bootstrap script per side that requires and initializes all services/controllers
4. **CollectionService tags** — tag instances in editor, use Component-pattern modules for behavior (decouples code from instance hierarchy)
5. **Attributes over Value objects** — use Instance attributes for per-instance config (damage, speeds, etc.)
