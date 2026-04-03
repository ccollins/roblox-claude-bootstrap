local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Services
-- require(script.Services.MyService)

Knit.Start()
	:andThen(function()
		print("[Server] Knit started successfully")
	end)
	:catch(function(err)
		warn("[Server] Knit failed to start:", err)
	end)
