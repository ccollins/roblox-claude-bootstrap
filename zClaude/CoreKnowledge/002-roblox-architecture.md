# Roblox Architecture Reference

## The DataModel

The DataModel (`game`) is the root of a parent-child instance tree. Its direct children are **services**.

### Service Map

| Service | Replicated to Client? | Purpose |
|---------|----------------------|---------|
| **Workspace** | Yes (streamed) | 3D world — parts, models, terrain. With StreamingEnabled, only nearby content is sent. |
| **ReplicatedFirst** | Yes (once, first) | Objects needed immediately at client startup (loading screens, essential LocalScripts). |
| **ReplicatedStorage** | Yes (all clients) | Shared modules, RemoteEvents/Functions, assets needed by both sides. |
| **ServerScriptService** | **Never** | Server Scripts and their ModuleScripts. Invisible to clients. |
| **ServerStorage** | **Never** | Server-only assets, data templates, NPC models before spawning. |
| **StarterPlayer** | Cloned per player | StarterPlayerScripts (LocalScripts) and StarterCharacterScripts. |
| **StarterGui** | Cloned per player | UI ScreenGuis cloned to each player's PlayerGui on join/respawn. |
| **StarterPack** | Cloned per player | Tools given to each player. |
| **Lighting** | Yes | Atmosphere, sky, lighting effects. |
| **SoundService** | Yes | Global sound settings. |
| **Players** | Partial | Player objects visible to all, but not all children. |
| **Teams** | Yes | Team definitions. |

### Client-Server Runtime Flow

1. Roblox copies the "edit" DataModel to create the server runtime DataModel
2. Server Scripts in ServerScriptService execute
3. Player joins → server sends a copy of the runtime DataModel (**minus** ServerScriptService and ServerStorage)
4. Client receives ReplicatedFirst contents first, then the rest
5. LocalScripts in StarterPlayerScripts, StarterCharacterScripts, and StarterGui execute on the client

### Replication

Three things replicate:
1. **DataModel changes** — instances created/modified, property changes
2. **Physics simulation** — position, velocity, rotation of unanchored parts
3. **Chat messages** — filtered through the server

Directions:
- **Client → Server**: Player fires a RemoteEvent (e.g., "I pressed E")
- **Server → One Client**: Server sends data to a specific player
- **Server → All Clients**: Server broadcasts (e.g., day/night cycle)

Typical network latency: **100-300ms**.

## Streaming Enabled

When `Workspace.StreamingEnabled = true`, the server only sends nearby 3D content.

Key properties:
- `StreamingMinRadius` — highest priority load radius (keep small)
- `StreamingTargetRadius` — max stream-in distance
- `StreamingIntegrityMode` — behavior when streaming can't keep up

**Code implications:**
- Parts far from the player may not exist on the client
- Use `WaitForChild` or Streamable utility patterns
- Models can use `ModelStreamingMode.Atomic` to stream as a unit
