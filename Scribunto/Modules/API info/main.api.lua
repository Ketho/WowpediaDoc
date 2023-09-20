local modules = {
	flavor = require("Module:API_info/flavor"),
	elink = require("Module:API_info/elink"),
	patch = require("Module:API_info/patch"),
	-- metrics = require("Module:API_info/metrics"),
	group = require("Module:API_info/group"),
	flavorbox = require("Module:API_info/flavor_ambox"),
	infobox = require("Module:API_info/util/infobox"),
}
local m = {}

local comparison = {
	a = "Global_functions/Classic",
	e = "Events/Classic",
}

local template = {
	title = "api ambox",
	args = {
		border = "red",
		image = "Spell_arcane_portalstormwind",
		size = 72,
		format = "normal",
		info = "<font size=3>See [[Forum:Vote to Leave Fandom]].</font>",
		"<font size=3>'''The API docs will be forked to possibly [https://wiki.gg/ wiki.gg]'''</font>",
	}
}

local PTR_VERSION = "10.2.0"

local function GetDefaultInfobox(args, name)
	local added, removed = modules.patch:GetPatches(args.t, name)
	if #added > 0 then -- check if we have data on this since {{wowapi}} doesnt guarantee its an API
		local t = {}
		local flavors = modules.flavor:GetFlavors(args.t, name)
		if flavors then
			table.insert(t, string.format("! Flavors", comparison[args.t]))
			table.insert(t, flavors)
		end
		local elinks = modules.elink:GetElinks(args.t, name)
		if #elinks > 0 then
			table.insert(t, "! Links")
			table.insert(t, elinks)
		end
		table.insert(t, "! Info")
		table.insert(t, "| Added in "..added)
		if #removed > 0 then
			table.insert(t, "| Removed in "..removed)
		end
		-- local metrics = modules.metrics:main(args.t, name)
		-- if metrics then
		-- 	table.insert(t, "| "..modules.metrics:GetScoreString(metrics, true))
		-- end
		return t
	end
end

local function GetInfobox(f, name)
	local infobox
	if modules.group:GetData(name) then
		infobox = modules.group:main(f.args, name)
	else
		local defaultInfobox = GetDefaultInfobox(f.args, name)
		if defaultInfobox then
			infobox = modules.infobox:main(defaultInfobox)
		end
	end
	return infobox
end

local ptrAmbox = {
	title = "Ambox",
	args = {
		border = "green",
		image = "[[File:PTR_client.png|32px|link=]]",
		style = "width: auto; margin-left: 0.8em;",
		type = string.format("'''This API only exists on the %s ''[[Public Test Realm]]'''''", PTR_VERSION),
	}
}

local function GetPtrAmbox(f, name)
	local isPtr = modules.patch:IsPTR(f.args.t, name, PTR_VERSION)
	if isPtr then
		return f:expandTemplate(ptrAmbox)
	end
end

function m.main(f)
	local PAGENAME = f.args[1]
	local name = PAGENAME:gsub("API ", ""):gsub(" ", "_")
	local text = ""
	local infobox = GetInfobox(f, name)
	local flavorbox = modules.flavorbox:GetAmbox(f, name)
	local ptrBox = GetPtrAmbox(f, name)
	text = text..f:expandTemplate(template)
	if infobox then
		text = text..infobox
	end
	if flavorbox then
		text = text..flavorbox
	end
	if ptrBox then
		text = text..ptrBox
	end
	return text
end

return m
