local util = require("wowdoc")
local FRAMEXML = "../#FrameXML/Generate-Globals/wow-ui-source/"

local m = {}

local string_tbl = {}

function m:ReadFile(path)
	local file = io.open(path, "r")
	local text = file:read("a")
	file:close()
	return text
end

local function GetStrings(path)
	local text = m:ReadFile(path)
	for s in text:gmatch('"(.-)"') do
		string_tbl[s:lower()] = true
	end
end

local function GetCvars()
	local data = util:DownloadAndRun(
		"https://raw.githubusercontent.com/Ketho/BlizzardInterfaceResources/mainline/Resources/CVars.lua",
		"cache_lua/CVars_mainline.lua"
	)
	return data[1].var
end

local function WriteTable(tbl)
	local file = io.open("KethoWowpedia/scripts/cvar_framexml.lua", "w")
	file:write("local m = KethoWowpedia\n\nm.cvar_framexml = {\n")
	local fs = '\t["%s"] = true,\n'
	for _, name in pairs(util:SortTable(tbl, util.SortNocase)) do
		file:write(fs:format(name))
	end
	file:write("}\n")
	file:close()
end

local function main()
	util:IterateFiles(FRAMEXML, GetStrings)
	local t = {}
	for k in pairs(GetCvars()) do
		-- there are some cvars that dont match case insensitive
		if string_tbl[k:lower()] then
			t[k] = true
		end
	end
	WriteTable(t)
end

main()
print("done")
