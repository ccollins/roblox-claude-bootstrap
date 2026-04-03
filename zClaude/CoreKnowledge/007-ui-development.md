# UI Development

## React-Lua (Recommended for Complex UI)

Official Roblox port of React 17.x to Luau. Replaces the deprecated Roact.

**No JSX** — use `React.createElement` directly:

```lua
local React = require(Packages.React)
local ReactRoblox = require(Packages.ReactRoblox)

local function HealthBar(props)
    local health, setHealth = React.useState(100)

    React.useEffect(function()
        local conn = props.Humanoid.HealthChanged:Connect(function(newHealth)
            setHealth(newHealth)
        end)
        return function() conn:Disconnect() end
    end, {props.Humanoid})

    return React.createElement("Frame", {
        Size = UDim2.new(health / 100, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 255, 0),
    })
end

local container = playerGui:WaitForChild("HealthScreen")
local root = ReactRoblox.createRoot(container)
root:render(React.createElement(HealthBar, { Humanoid = humanoid }))
```

### Available Hooks

`useState`, `useEffect`, `useContext`, `useReducer`, `useRef`, `useCallback`, `useMemo`, `useBinding` (Roblox-specific — zero-cost property updates without re-render)

### Roblox-Specific Extensions

- `React.Event.Activated` — connect to Roblox events on elements
- `React.Change.Text` — listen to property changes
- `React.Tag` — apply CollectionService tags
- `React.createBinding()` — efficient animated properties

### Key Differences from JS React

- `useState` returns two values (not array): `local val, setVal = React.useState(0)`
- No JSX — all `createElement` calls
- Dependency arrays with nil values can cause issues (Luau length operator)
- Concurrent mode is default with `createRoot`

## Fusion (Alternative)

Reactive UI library built for Luau. Simpler API than React-Lua, built-in animations (tweens/springs). Good for teams that find React too heavy.

## When to Use Which

- **Simple UI** (menus, HUDs with few elements): Traditional ScreenGui scripting
- **Complex, dynamic UI** (inventories, shops, chat, settings): React-Lua or Fusion
- **Performance-critical animations**: `React.useBinding` or Fusion's reactive animations
