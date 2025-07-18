-- https://warcraft.wiki.gg/wiki/API_UnitCreatureFamily
local util = require("util")
local parser = require("util.wago")
local dbc_patch = require("Projects/DBC/DBC_patch")
local OUTPUT = "out/page/UnitCreatureFamily.txt"
local wago = require("util.wago")

local patch_override = {
	["7.3.5"] = "",
}

local function GetWikiIcon(filedata, fileid)
    local s = ""
    fileid = tonumber(fileid)
    if fileid > 0 then
        local icon = filedata[fileid]
        s = icon:gsub("interface/icons/", "")
        s = s:gsub("%.blp", "")
        s = string.format("[[File:%s.png|24px|link=]]", s)
    end
    return s
end

local function main(options)
	options = util:GetFlavorOptions(options)
	options.initial = false
    options.sort = util.SortBuild
    local patchData = dbc_patch:GetPatchData("creaturefamily", options)
    local listfile = wago:ReadListfile()
	local fs = "|-\n| %d || %s || %s || %s\n"
	local file = io.open(OUTPUT, "w")
	file:write('{| class="sortable darktable zebra col1-center col2-center"\n! ID !! Icon !! Name (enUS) !! Patch\n')
	util:ReadCSV("creaturefamily", parser, options, function(_, ID, l)
		local patch = util:GetPatchText(patchData, ID, patch_override)
        local icon = GetWikiIcon(listfile, l.IconFileID)
		file:write(fs:format(ID, icon, l.Name_lang, patch))
	end)
	file:write("|}\n")
	file:close()
	print("written "..OUTPUT)
end

main()
print("done")
