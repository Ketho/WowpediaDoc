local util = require("util")

local m = {}

function m:main(branch)
	util:LoadLuaEnums(branch)
	util:LoadDocumentation(branch)
	local globalApi = util:DownloadAndRun(
		string.format("cache_lua/GlobalAPI_%s.lua", branch),
		string.format("https://raw.githubusercontent.com/Ketho/BlizzardInterfaceResources/%s/Resources/GlobalAPI.lua", branch)
	)

	local blizzDoc = {}
	for _, func in ipairs(APIDocumentation.functions) do
		local name = util:GetFullName(func)
		blizzDoc[name] = func.System:GetName()
	end

	local nonBlizzDocumented = {}
	for _, name in pairs(globalApi[1]) do
		if not blizzDoc[name] then
			nonBlizzDocumented[name] = true
		end
	end

	return {blizzDoc, nonBlizzDocumented}
end

return m
