local Util = require("Util/Util")
local FrameXML = require("Documenter/FrameXML/FrameXML")
FrameXML:LoadApiDocs("Documenter/FrameXML")

local globalApi = Util:DownloadAndRun(
	"cache/GlobalAPI_mainline.lua",
	"https://raw.githubusercontent.com/Ketho/BlizzardInterfaceResources/mainline/Resources/GlobalAPI.lua"
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
