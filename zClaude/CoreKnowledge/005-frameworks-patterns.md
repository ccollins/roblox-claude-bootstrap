# Game Frameworks & Patterns

## Knit (by sleitnick)

Most widely adopted Roblox framework. Service/Controller pattern with automatic networking.

- **Services** (server-side singletons): game logic, expose methods/signals to clients
- **Controllers** (client-side singletons): input, UI, local effects
- Auto-creates RemoteEvents/RemoteFunctions — never manually create them

```lua
-- Server: GameService
local Knit = require(Packages.Knit)

local GameService = Knit.CreateService({
    Name = "GameService",
    Client = {
        ScoreChanged = Knit.CreateSignal(), -- auto RemoteEvent
    },
})

function GameService:KnitStart()
    -- Runs after all services initialized
end

function GameService.Client:GetScore(player)
    -- Auto RemoteFunction, callable from client
    return self.Server:_getScore(player)
end
```

**Status:** No longer receiving updates but stable and widely used. Wally: `sleitnick/knit@1.6.0`

**RbxUtil** (companion library): Signal, Timer, TableUtil, Streamable, Component, and more.

## ProfileService / ProfileStore

Standard for player data management. ProfileStore is the newer version.

**Session Locking** (the killer feature):
- On load, `UpdateAsync` writes a session lock with current server's JobId
- If player joins another server before release, new server detects the lock
- Waits for release or steals after timeout (for crashed servers)
- Prevents item duplication from dual-server edits

```lua
local ProfileService = require(Packages.ProfileService)
local ProfileStore = ProfileService.GetProfileStore("PlayerData", {
    Coins = 0,
    Inventory = {},
    Level = 1,
})

Players.PlayerAdded:Connect(function(player)
    local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)
    if profile then
        profile:AddUserId(player.UserId) -- GDPR compliance
        profile:Reconcile() -- Fills missing keys from template
        profile:ListenToRelease(function()
            player:Kick("Data loaded on another server")
        end)
        profile.Data.Coins += 100
    end
end)
```

## Matter ECS

Entity-Component-System for data-driven game architecture. Ideal for many interacting entities.

- **Entities**: Just IDs (numbers)
- **Components**: Pure data tables attached to entities
- **Systems**: Functions that query/process entities by components
- Fast archetype-based storage
- Wally: `matter-ecs/matter`

## Component Pattern (from RbxUtil)

Bridges CollectionService tags to OOP classes:

```lua
local Component = require(Packages.Component)

local Lava = Component.new({ Tag = "Lava" })

function Lava:Construct()
    -- called when a tagged instance appears
end

function Lava:Start()
    self.Instance.Touched:Connect(function(hit) ... end)
end

function Lava:Stop()
    -- cleanup
end
```

## Module Organization Principles

Regardless of framework:
- **Server services** handle authoritative game state
- **Client controllers** handle input, UI, local effects
- **Shared modules** contain types, constants, utilities, data structures
- Communication: Client → Remote → Server Service → processes → Remote → Client Controller → UI
