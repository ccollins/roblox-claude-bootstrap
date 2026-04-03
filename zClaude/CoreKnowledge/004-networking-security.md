# Networking & Security

## RemoteEvents vs RemoteFunctions

### RemoteEvent — one-way, fire-and-forget, async

```lua
-- Client → Server
remoteEvent:FireServer(itemName, quantity)

-- Server handler (player auto-injected as first arg)
remoteEvent.OnServerEvent:Connect(function(player, itemName, quantity)
    -- validate and process
end)

-- Server → Specific Client
remoteEvent:FireClient(targetPlayer, data)

-- Server → All Clients
remoteEvent:FireAllClients(data)
```

### RemoteFunction — two-way, yields until response

```lua
-- Client invokes server
local result = remoteFunction:InvokeServer(args)

-- Server callback
remoteFunction.OnServerInvoke = function(player, args)
    return processedResult
end
```

### UnreliableRemoteEvent

Trades reliability/ordering for performance. Use for continuous data (position hints, cosmetic effects) where dropped packets are acceptable.

### When to Use Which

- **RemoteEvent**: Almost always. Player actions, UI updates, notifications
- **RemoteFunction**: Only when client truly needs a return value AND can tolerate yielding
- **Never use `InvokeClient`**: If client disconnects, server yields forever

### Argument Limitations (Critical)

- Non-string table keys auto-convert to strings
- Functions passed as arguments become `nil`
- Mixed tables (numeric + string keys) are unreliable
- Tables are deep-copied (not referenced)
- Metatables are stripped
- Instances in ServerStorage/ServerScriptService sent to clients become `nil`

## Security

### Golden Rule: Never Trust the Client

Everything from the client is potentially forged.

### Server-Side Rate Limiting

```lua
local cooldowns = {}
local COOLDOWN = 0.2

remoteEvent.OnServerEvent:Connect(function(player, ...)
    local now = tick()
    if cooldowns[player.UserId] and (now - cooldowns[player.UserId]) < COOLDOWN then
        return
    end
    cooldowns[player.UserId] = now
    -- process
end)
```

### Input Validation Pattern

```lua
remoteEvent.OnServerEvent:Connect(function(player, itemName, quantity)
    -- Validate types
    if typeof(itemName) ~= "string" then return end
    if typeof(quantity) ~= "number" then return end

    -- Validate ranges
    if quantity ~= math.floor(quantity) then return end  -- integer check
    if quantity < 1 or quantity > 99 then return end
    if quantity ~= quantity then return end  -- NaN check

    -- Validate string length
    if #itemName > 50 then return end

    -- Validate against whitelist
    if not itemRegistry[itemName] then return end

    -- Look up values SERVER-SIDE (never use client-sent prices)
    local price = itemRegistry[itemName].Price
end)
```

### Key Principles

- Never send prices, damage values, or currency amounts from client to server
- Only send identifiers (item names, action types) — look up real values server-side
- Validate every argument: type, range, NaN, length
- Use `task.spawn` for heavy processing to avoid queue exhaustion

### Common Vulnerabilities & Mitigations

| Vulnerability | Mitigation |
|--------------|------------|
| Remote spam | Server-side rate limiting per player |
| Forged remote args | Type check, range check, whitelist validate |
| Client-sent prices/damage | Never use client values for authoritative calculations |
| Speed/fly hacks | Server-side position validation |
| Duplicated items | Session locking on data (ProfileService) |
| Memory editing | Server authority; never trust client state |

### Network Ownership Risks

When a client has network ownership of a part, they can teleport it, change velocity, modify WalkSpeed locally, fling other players, fire fake Touched events.

**Mitigations:**
1. Server-side movement validation with leaky-bucket accumulators
2. Set NPC network ownership to server for critical NPCs: `npc.PrimaryPart:SetNetworkOwner(nil)`
3. Server-side hit detection for combat (client sends click position, server raycasts)
4. Periodic server-side position sanity checks
