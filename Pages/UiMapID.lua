-- https://wowpedia.fandom.com/wiki/UiMapID#Classic
local Util = require("Util/Util")
-- local parser = require("Util/wowtoolsparser")
local parser = require("Util/wago_csv")
local wowpedia_export = require("Util/wowpedia_export")
local dbc_patch = require("Projects/DBC/DBC_patch")

local OUTPUT = "KethoWowpedia/patch/uimap.lua"

local function main(options)
	options = Util:GetFlavorOptions(options)
	local patchData = dbc_patch:GetPatchData("uimap", options)
	print("writing to "..OUTPUT)
	local file = io.open(OUTPUT, "w")
	
	local fs = '\t[%d] = "%s",\n'
	file:write("KethoWowpedia.patch.uimap = {\n")
	Util:ReadCSV("uimap", parser, options, function(_, ID, l)
		local patch = patchData[ID] and Util:GetPatchVersion(patchData[ID].patch) or ""
		file:write(fs:format(ID, patch))
	end)
	file:write("}\n")
	file:close()
end

main("mainline")
print("done")
