-- https://wowpedia.fandom.com/wiki/Module:API_info
-- https://github.com/Ketho/WowpediaApiDoc/blob/master/Projects/Scribunto/API_info/API_info.lua
local bit = require "bit32"
local flavor_data = mw.loadData("Module:API_info/flavor")
local elink_module = require("Module:API_info/elink")
local m = {}

local icons = {
	{id = 0x1, label = "[[File:Shadowlands-Logo-Small.png|34px|link=]] retail"},
	{id = 0x4, label = "[[File:Bc icon.gif|link=]]&nbsp; bcc"},
	{id = 0x2, label = "[[File:WoW Icon update.png|link=]] classic_era"},
}

-- mimicks [[Template:apinav]
local boxPattern = [=[
{| class="darktable nomobile" style="min-width:142px; float:right; clear:right;"
! Game [[Global_functions/Classic|Flavors]]
|-
| %s
|-
! Links
|-
| %s
|}
]=]

local function GetInfobox(name, flavors)
	local t = {}
	for _, v in pairs(icons) do
		if bit.band(flavors, v.id) > 0 then
			table.insert(t, v.label)
		end
	end
	local flavorText = table.concat(t, "<br>")
	local blizzdocText = elink_module.GetElinks(name)
	return boxPattern:format(flavorText, blizzdocText)
end

function m.main(f)
	local name = f.args[1]
	name = name:gsub("API ", "")
	name = name:gsub(" ", "_")
	local flavors = flavor_data[name]
	if flavors then
		local infobox = GetInfobox(name, flavors)
		return infobox
	end
end

return m
