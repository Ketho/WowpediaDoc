-- https://wowpedia.fandom.com/wiki/Module:API_info/patch/event_retail
-- https://wowpedia.fandom.com/wiki/Module:API_info/patch/event_classic
local lfs = require("lfs")
local write_table = require("wowdoc.write_table")
local util = require("wowdoc")
local enum = require("wowdoc.enum")

local BRANCH = "mainline" ---@type BlizzResBranch
enum:LoadLuaEnums(BRANCH)

local flavors = {
	mainline = {
		id = "mainline",
		input = "FrameXML/mainline",
		out = "out/lua/API_info.patch.event_retail.lua",
	},
	classic = {
		id = "classic",
		input = "FrameXML/vanilla",
		out = "out/lua/API_info.patch.event_classic.lua",
	},
}

-- 10.0.0 / 3.4.0: fix CharacterCustomizationSharedDocumentation.lua
CHAR_CUSTOMIZE_CUSTOM_DISPLAY_OPTION_FIRST = 5
CHAR_CUSTOMIZE_CUSTOM_DISPLAY_OPTION_LAST = 8

-- caches the results after scanning
local function GetFrameXmlData(tbl_apidoc)
	local path = "Scribunto/API_info/patch/event/framexml_data.lua"
	local data
	if not lfs.attributes(path) then
		local FrameXML = require("Scribunto/API_info/patch/event/FrameXML")
		data = FrameXML:main(flavors, tbl_apidoc)
		write_table(data, path)
	else
		data = loadfile(path)()
	end
	return data
end

local function WritePatchData(flavor)
	-- get event patch data from >8.0.1 blizzard api docs
	print("-- reading Blizzard_APIDocumentation", flavor.id)
	local BlizzardApiDoc = require("Scribunto/API_info/patch/event/BlizzardApiDoc")
	local tbl_apidoc = BlizzardApiDoc:main(flavors)
	if flavor.id == "mainline" then
		-- get older event data by looking through framexml
		print("-- reading framexml")
		local tbl_framexml = GetFrameXmlData(tbl_apidoc)
		-- fill in false values
		for k, v in pairs(tbl_framexml) do
			tbl_apidoc.mainline[k][1] = v
		end
	end
	print("writing", flavor.out)
	write_table(tbl_apidoc[flavor.id], flavor.out)
	local file = io.open(flavor.out, "a+")
	file:write("-- https://github.com/Ketho/WowpediaApiDoc/blob/master/Scribunto/API_info/patch/event/event.lua\n")
	file:close()
end

local function main()
	WritePatchData(flavors.mainline)
	WritePatchData(flavors.classic)
end

main()
