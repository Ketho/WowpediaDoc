local patch_retail = loadfile("out/lua/API_info.patch.api_retail.lua")()
local flavor = loadfile("out/lua/API_info.flavor.api.lua")()
local util = require("util")

local function GetNotExist()
	for _, k in pairs(util:SortTable(patch_retail)) do
		if not flavor[k] then
			print(k)
		end
	end
end
GetNotExist()
