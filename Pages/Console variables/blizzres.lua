local util = require("util")

local function main()
	local data = util:DownloadAndRun(
		string.format("https://raw.githubusercontent.com/Ketho/BlizzardInterfaceResources/%s/Resources/CVars.lua", "mainline_ptr"),
		string.format("cache_lua/CVars_%s.lua", "mainline_ptr")
	)
	return data
end

return main
