local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Controllers
-- require(script.Controllers.MyController)

Knit.Start()
	:andThen(function()
		print("[Client] Knit started successfully")
	end)
	:catch(function(err)
		warn("[Client] Knit failed to start:", err)
	end)
