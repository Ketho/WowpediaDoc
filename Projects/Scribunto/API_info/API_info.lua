local bit = require "bit32"
local flavor_data = mw.loadData("Module:API_info/flavor")
local m = {}

-- use icons instead of templates
local flags = {
	{id = 0x1, label = "[[File:Shadowlands-Logo-Small.png|34px|link=]] retail"}, -- {{sl-inline}}
	{id = 0x2, label = "[[File:WoW Icon update.png|link=]] classic_era"}, -- {{wow-inline}}
	{id = 0x4, label = "[[File:Bc icon.gif|link=]]&nbsp; bcc"}, -- {{bc-inline}}
}

-- mimicks [[Template:apinav]
local boxPattern = [=[
{| class="darktable nomobile" style="margin:0; max-width:20vw; min-width:120px; float:right; clear:right;"
|-
! %s
|-
| %s<br />%s
|}
]=]

local function GetInfobox(f, name, flavors)
	local t = {}
	for _, v in pairs(flags) do
		if bit.band(flavors, v.id) > 0 then
			table.insert(t, v.label)
		end
	end
	return boxPattern:format(name, "[[Global_functions/Classic|Flavors]]", table.concat(t, "<br />"))
end

function m.main(f)
	local name = f.args[1]
	name = name:gsub("API ", "")
	name = name:gsub(" ", "_")
	local flavors = flavor_data[name]
	if flavors then
		local infobox = GetInfobox(f, name, flavors)
		return infobox
	end
end

return m
