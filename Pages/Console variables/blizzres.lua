local Util = require("Util.Util")

local function main()
	local data = Util:DownloadAndRun(
		string.format("cache_lua/CVars_%s.lua", BRANCH),
		string.format("https://raw.githubusercontent.com/Ketho/BlizzardInterfaceResources/%s/Resources/CVars.lua", BRANCH)
	)
	return data
end

return main
