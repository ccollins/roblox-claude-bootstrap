# Performance

## Common Pitfalls

- **Excessive part count** — aim for under 10,000 parts in Workspace. Use MeshParts or Unions to combine geometry.
- **Unanchored parts with server network ownership** — server physics is expensive. Let clients own physics for nearby objects.
- **While loops without yielding** — `while true do end` freezes the thread. Always include `task.wait()`.
- **Connecting events without disconnecting** — memory leaks. Store connections, call `:Disconnect()` on cleanup.
- **Global variable access** — slower than locals. Cache: `local Workspace = workspace`
- **Frequent DataStore calls** — batch data, cache locally, save on intervals
- **Large tables in ReplicatedStorage** — everything there replicates to all clients
- **Creating instances every frame** — pool and reuse instead

## Instance Cleanup

`Instance:Destroy()` disconnects all events, sets Parent to nil, locks the instance. Always call it.

## Memory Management

- Set table references to nil to allow GC
- Avoid circular references
- Store connections in a table and disconnect all on cleanup
- Use `table.concat` instead of `..` in loops (each `..` creates a new string)

## MicroProfiler

Press **Ctrl+Alt+F6** in-game or Studio.

- Shows per-frame timing of every subsystem
- Instrument your own code:

```lua
debug.profilebegin("MyExpensiveOperation")
-- ... code ...
debug.profileend()
```

## Key Metrics

- Target **60 FPS** (16.67ms per frame)
- Server heartbeat: **60 Hz** by default
- Network latency: **100-300ms** typical
