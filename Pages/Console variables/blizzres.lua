local Util = require("Util.Util")

local function main()
	local data = Util:DownloadAndRun(
		string.format("cache_lua/CVars_%s.lua", "mainline"),
		string.format("https://raw.githubusercontent.com/Ketho/BlizzardInterfaceResources/%s/Resources/CVars.lua", "mainline")
	)
	return data
end

return main
