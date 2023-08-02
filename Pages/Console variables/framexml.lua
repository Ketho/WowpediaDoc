local Util = require("Util.Util")
-- local parser = require "Util/wago_csv"

local framexml_strings = {}

local function ReadFile(path)
	local file = io.open(path, "r")
	local text = file:read("a")
	file:close()
	return text
end

local function GetStrings(path)
	local text = ReadFile(path)
	for s in text:gmatch('"(.-)"') do
		framexml_strings[s:lower()] = true
	end
end

local function main(blizzres)
	local frameXML = Util:GetLatestBuild(BRANCH)
	Util:IterateFiles(frameXML, GetStrings)
	local framexml_cvars = {}
	for k, v in pairs(blizzres[1].var) do
		if framexml_strings[k:lower()] then
			framexml_cvars[k] = true
		end
	end
	return framexml_cvars
end

return main
