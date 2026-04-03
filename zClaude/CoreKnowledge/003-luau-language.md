# Luau Language Reference

## Overview

Luau is based on Lua 5.1 but is **not** a superset of later Lua versions. It's independently evolved with its own type system, optimizations, and syntax additions.

## Key Syntax Additions Over Lua 5.1

- **Augmented assignment**: `+=`, `-=`, `*=`, `/=`, `%=`, `^=`, `..=`
- **String interpolation**: `` `Hello {playerName}, you have {coins} coins` ``
- **Ternary expression**: `local x = if condition then valueA else valueB`
- **`continue`** keyword in loops
- **Generalized iteration**: `for k, v in table do` (no need for `pairs`)
- **Type annotations** (see below)

## Type System

Luau uses **structural typing** (not nominal). Three modes, set per-file on line 1:

```lua
--!strict    -- Asserts all types based on inferred or explicit annotations
--!nonstrict -- Only asserts where explicitly annotated (default)
--!nocheck   -- Disables type checking entirely
```

### Annotation Syntax

```lua
-- Primitives
local name: string = "hello"
local health: number = 100
local alive: boolean = true

-- Functions
local function damage(target: Humanoid, amount: number): number
    target.Health -= amount
    return target.Health
end

-- Optional (nullable)
local data: string? = nil

-- Union types
type StringOrNumber = string | number

-- Intersection types
type Combined = TypeA & TypeB

-- Table types
local scores: {[string]: number} = {Alice = 100, Bob = 85}
local list: {number} = {1, 2, 3}

-- Generics
type Array<T> = {T}
type Map<K, V> = {[K]: V}

-- Function types
type Callback = (player: Player, action: string) -> boolean

-- Export types from modules
export type WeaponConfig = {
    Name: string,
    Damage: number,
    FireRate: number,
}

-- Type casts
local value = someUnknown :: number

-- typeof for engine types
type CarType = typeof({ Speed = 0, Wheels = 4 })
```

## Performance Best Practices

- **Always use `local`** — global variables disable optimizations
- Use `task.spawn`, `task.delay`, `task.wait` over legacy `spawn`, `delay`, `wait`
- Cache service references: `local Players = game:GetService("Players")`
- Avoid string concatenation in loops — use `table.concat`
- Use `--!strict` mode for all new code
- Define types for all module interfaces using `export type`
- Avoid `any` — use union types instead
- Use `typeof()` to reference engine types

## Sandboxing

No `os`, `io`, `loadstring` by default. Luau runs in a sandboxed execution model within Roblox.
