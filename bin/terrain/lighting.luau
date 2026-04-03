--!strict
--[[
	Lighting — Starter Template

	Run via MCP execute_luau or Studio Command Bar.
	Customize for your game's atmosphere.
]]

local Lighting = game:GetService("Lighting")

Lighting.ClockTime = 14
Lighting.GeographicLatitude = 40
Lighting.Brightness = 2
Lighting.GlobalShadows = true

local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
if not atmo then atmo = Instance.new("Atmosphere"); atmo.Parent = Lighting end
atmo.Density = 0.3
atmo.Offset = 0.25

print("[Lighting] Applied")
