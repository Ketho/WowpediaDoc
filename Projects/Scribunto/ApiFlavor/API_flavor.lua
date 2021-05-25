local bit = require "bit32"
local data = mw.loadData("Module:API_flavor/data")
local m = {}

local flags = {
	[0x1] = "[[File:Shadowlands-Logo-Small.png|34px|link=]] live",
	[0x2] = "[[File:Bc icon.gif|link=]]&nbsp; bcc",
	[0x4] = "[[File:WoW Icon update.png|link=]] classic_era",
}

-- todo: make our own derivative infobox template
local function GetInfobox(f, name, flavors)
	local t = {}
	for flag, text in pairs(flags) do
		if bit.band(flavors, flag) > 0 then
			table.insert(t, text)
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
