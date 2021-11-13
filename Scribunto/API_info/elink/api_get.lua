local PATH = "cache/GlobalAPI_mainline.lua"
local URL = "https://raw.githubusercontent.com/Ketho/BlizzardInterfaceResources/mainline/Resources/GlobalAPI.lua"

local Util = require("Util/Util")
local FrameXML = require("Documenter/FrameXML/FrameXML")
FrameXML:LoadApiDocs("Documenter/FrameXML")

Util:DownloadFile(PATH, URL, true)
local globalApi = require(PATH:gsub("%.lua", ""))[1]

local blizzDoc = {}
for _, func in ipairs(APIDocumentation.functions) do
	local name = Util:GetFullName(func)
	blizzDoc[name] = func.System:GetName()
end

local nonBlizzDocumented = {}
for _, name in pairs(globalApi) do
	if not blizzDoc[name] then
		nonBlizzDocumented[name] = true
	end
end

return {blizzDoc, nonBlizzDocumented}
