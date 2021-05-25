local bit = require "bit32"
local data = mw.loadData("Module:API_flavor/data")
local m = {}

local flags = {
	{id = 0x1, label = "[[File:Shadowlands-Logo-Small.png|34px|link=]] live"},
	{id = 0x4, label = "[[File:Bc icon.gif|link=]]&nbsp; bcc"},
	{id = 0x2, label = "[[File:WoW Icon update.png|link=]] classic_era"},
}

-- todo: make our own derivative infobox template
local function GetInfobox(f, name, flavors)
	local t = {}
	for _, v in pairs(flags) do
		if bit.band(flavors, v.id) > 0 then
			table.insert(t, v.label)
		end
	end
	local infobox = f:expandTemplate{
		title = 'Infobox',
		args = {
			header1 = name,
			label2 = "Flavors",
			data2 = table.concat(t, "<br>"),
		}
	}
	return infobox
end

function m.main(f)
	local name = f.args[1]
	name = name:gsub("API ", "")
	name = name:gsub(" ", "_")
	local flavors = data[name]
	if flavors then
		local infobox = GetInfobox(f, name, flavors)
		return infobox
	end
end

return m
