--!strict
--[[
	Terrain Generator — Starter Template

	Run via:
	  - MCP execute_luau (paste contents or require)
	  - Studio Command Bar (View → Command Bar)

	This CLEARS existing terrain and all generated folders, then
	regenerates from scratch. Deterministic — same seed produces
	the same world every time.

	Customize this script for your game's world.
]]

local terrain = workspace.Terrain
local RNG = Random.new(42)

-- Clean slate
terrain:Clear()

local baseplate = workspace:FindFirstChild("Baseplate")
if baseplate then baseplate:Destroy() end
local spawnLoc = workspace:FindFirstChild("SpawnLocation")
if spawnLoc then spawnLoc:Destroy() end

-- ============================================================================
-- Ground
-- ============================================================================

terrain:FillBlock(CFrame.new(0, -6, 0), Vector3.new(500, 12, 500), Enum.Material.Grass)

-- ============================================================================
-- Add your terrain generation here
-- ============================================================================

-- Example: a hill
-- terrain:FillBall(Vector3.new(100, -5, 0), 40, Enum.Material.Ground)
-- terrain:FillBall(Vector3.new(100, 1, 0), 38, Enum.Material.Grass)

-- Example: a pond (fill water FIRST, then displace with solid for shallow edges)
-- terrain:FillCylinder(CFrame.new(0, -8, 0), 16, 50, Enum.Material.Air)
-- terrain:FillCylinder(CFrame.new(0, -8, 0), 16, 50, Enum.Material.Water)

print("[Terrain] World generated")
