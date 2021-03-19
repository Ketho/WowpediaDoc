-- this place is a mess
local util = require "Util/util"

-- get global api
os.execute("mkdir out\\lua")
local api_path = "out/lua/GlobalAPI.lua"
local api_url = "https://raw.githubusercontent.com/Ketho/BlizzardInterfaceResources/live/Resources/GlobalAPI.lua"
util:DownloadFile(api_path, api_url)
local api = require(api_path:gsub("%.lua", ""))
local global_api = api[1]

-- parse arguments from wowpedia
local wowpedia_arguments = require "Pages/API/EmmyLua/FunctionParser"

-- get blizzard documented api
local FrameXML = require("FrameXML/FrameXML")
FrameXML:LoadApiDocs("FrameXML")
require "Wowpedia/Wowpedia"

local function GetFullName(func)
	local str
	if func.System.Namespace then
		str = format("%s.%s", func.System.Namespace, func.Name)
	else
		str = func.Name
	end
	return str
end

local blizzdocs = {}

for _, func in ipairs(APIDocumentation.functions) do
	local name = GetFullName(func)
	blizzdocs[name] = true
end

-- write emmylua to new files
os.execute("mkdir out\\emmylua")
local fileIndex = 0

local function GetOutputFile()
	fileIndex = fileIndex + 1
	local file = io.open(format("out/emmylua/Dump%d.lua", fileIndex), "w")
	return file
end

local fs = "---[Documentation](https://wow.gamepedia.com/API_%s)\nfunction %s(%s) end\n\n"
local count = 0
local outputFile = GetOutputFile()

-- lets just be lazy and grab all arguments from wowpedia
-- since the wowpedia page is already semi-automatically updated for documented api
for _, v in pairs(global_api) do
	if not blizzdocs[v] then
		outputFile:write(fs:format(v, v, wowpedia_arguments[v] or ""))
		count = count + 1
		if count == 500 then
			count = 0
			outputFile:close()
			outputFile = GetOutputFile()
		end
	end
end
