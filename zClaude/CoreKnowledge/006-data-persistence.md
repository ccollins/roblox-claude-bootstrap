# Data Persistence

## DataStoreService

Primary persistence layer.

- **4 MB** max per key
- Rate limits: 60 + (10 × playerCount) requests/min for Get/Set
- **UpdateAsync preferred over SetAsync** — atomic read-modify-write
- Data is versioned — supports rollback
- Always wrap in `pcall` (requests can fail)

### Best Practices

- Store all player data in a single key (one GetAsync/UpdateAsync per load)
- Use UpdateAsync for session locking and conflict resolution
- Implement exponential backoff retry on failures
- Save on `PlayerRemoving` AND in `game:BindToClose` for server shutdowns
- Cache data in memory; don't read from DataStore on every access

```lua
game:BindToClose(function()
    for _, player in Players:GetPlayers() do
        savePlayerData(player)
    end
end)
```

## OrderedDataStore

For leaderboards and rankings. Stores only integers. Supports `GetSortedAsync` for paginated sorted results.

## MemoryStoreService

In-memory, cross-server, ephemeral storage. Expires after up to 45 days.

| Structure | Use Case |
|-----------|----------|
| **SortedMap** | Leaderboards, cross-server auctions, matchmaking with priority |
| **Queue** | FIFO processing, task queues, matchmaking |
| **HashMap** | Caches, session data, feature flags, ephemeral counters |

**vs DataStore:** Much faster (in-memory), data expires, no versioning, higher request limits, size-limited.

## Session Locking (How ProfileService Does It)

The race condition: Player leaves Server A, joins Server B. Server B's LoadAsync might complete before Server A's save → data loss or duplication.

Solution:
1. On load, `UpdateAsync` writes `{ SessionLock = thisJobId, Data = ... }`
2. On subsequent loads, check if SessionLock matches a different server
3. If locked, wait and retry (other server should save and release)
4. If lock is stale (crashed server), steal after timeout
5. On release, `UpdateAsync` clears SessionLock and writes final data
