local Util = require("Util/Util")
local FrameXML = require("Documenter/FrameXML/FrameXML")
FrameXML:LoadApiDocs("Documenter/FrameXML")

local m = {}

function m:main(branch)
	local globalApi = Util:DownloadAndRun(
		string.format("cache_lua/GlobalAPI_%s.lua", branch),
		string.format("https://raw.githubusercontent.com/Ketho/BlizzardInterfaceResources/%s/Resources/GlobalAPI.lua", branch)
	)

	local blizzDoc = {}
	for _, func in ipairs(APIDocumentation.functions) do
		local name = Util:GetFullName(func)
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
