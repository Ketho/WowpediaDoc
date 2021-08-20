local lfs = require "lfs"
local Util = require("Util/Util")
local m = {}
local OUT_FILE = "out/page/Changes.txt"

m.ApiTypes = {
	GlobalAPI = {
		label = "Global API",
		text = ": {{api|t=a|%s}}",
		parseName = function(innerLine)
			return innerLine:match('\t"(.+)",')
		end,
		class = "mw-customtoggle-global-c",
		id = "mw-customcollapsible-global-c",
	},
	WidgetAPI = {
		label = "Widgets",
		text = ": {{api|t=w|%s}}",
		parseName = function(innerLine)
			return innerLine:match('\t\t\t"(.+)",')
		end,
		class = "mw-customtoggle-widgets",
		id = "mw-customcollapsible-widgets",
	},
	Events = {
		text = ": {{api|t=e|%s}}",
		parseName = function(innerLine)
			return innerLine:match('\t\t"(.+)",')
		end,
		class = "mw-customtoggle-events",
		id = "mw-customcollapsible-events",
	},
	CVars = {
		text = ": {{api|t=c|%s}}",
		parseName = function(innerLine)
			return innerLine:match('\t\t%["(.+)"%]')
		end,
		class = "mw-customtoggle-cvars",
		id = "mw-customcollapsible-cvars",
	},
}

local api_order = {"GlobalAPI", "WidgetAPI", "Events", "CVars"}

for _, v in pairs(m.ApiTypes) do
	v.changes = {
		["+"] = {},
		["-"] = {},
	}
end

-- https://github.com/Ketho/BlizzardInterfaceResources/commit/9f5b92ef5ee205a4df7536a145bbee24f678d5e0.diff
function m:FindDiff()
	local path
	for fileName in lfs.dir("Projects/ApiChanges") do
		if fileName:find("%.diff") then
			path = "Projects/ApiChanges/"..fileName
		end
	end
	return path
end

function m:ParseDiff(path)
	local file = io.open(path, "r")
	local section
	for line in file:lines() do
		if line:find("^diff") then
			section = line:match("(%a+)%.lua")
		end
		local isHeader = line:find("^%+%+%+ ") or line:find("^%-%-%- ")
		local sign, innerLine = line:match("^([%+%-])(.+)")
		if sign and not isHeader then
			local info = self.ApiTypes[section]
			local name = info and info.parseName(innerLine)
			if name then
				local text = info.text:format(name)
				table.insert(info.changes[sign], text)
			end
		end
	end
end

-- check if it's not a CVar name change
function m:SanitizeCVars()
	local added = Util:ToMap(self.ApiTypes.CVars.changes["+"])
	local removed = Util:ToMap(self.ApiTypes.CVars.changes["-"])
	for k in pairs(added) do
		if removed[k] then
			added[k] = nil
			removed[k] = nil
		end
	end
	-- cba safely removing while iterating
	Util:Wipe(self.ApiTypes.CVars.changes["+"])
	Util:Wipe(self.ApiTypes.CVars.changes["-"])
	for k in pairs(added) do
		table.insert(self.ApiTypes.CVars.changes["+"], k)
	end
	for k in pairs(removed) do
		table.insert(self.ApiTypes.CVars.changes["-"], k)
	end
end

function m:GetWikiTable(info, section)
	local t = {}
	table.insert(t, string.format('==%s==', info.label or section))
	table.insert(t, '{| class="wikitable" style="min-width: 600px"')
	table.insert(t, string.format('|- class="%s"', info.class))
	table.insert(t, string.format('! style="width: 50%%" | <font color="lightgreen">Added</font> <small>(%d)</small>', #info.changes["+"]))
	table.insert(t, string.format('! style="width: 50%%" | <font color="pink">Removed</font> <small>(%d)</small>', #info.changes["-"]))
	table.insert(t, string.format('|- class="mw-collapsible" id="%s"', info.id))
	table.insert(t, '| valign="top" | <div style="margin-left:-1.5em">')
	-- need to sort events at least, and cvars
	table.sort(info.changes["+"], Util.Sort_Nocase)
	for _, v in pairs(info.changes["+"]) do
		table.insert(t, v)
	end
	table.insert(t, '</div>')
	table.insert(t, '| valign="top" | <div style="margin-left:-1.5em">')
	table.sort(info.changes["-"], Util.Sort_Nocase)
	for _, v in pairs(info.changes["-"]) do
		table.insert(t, v)
	end
	table.insert(t, '</div>\n|}\n\n')
	return table.concat(t, "\n")
end

local function main()
	local path = m:FindDiff()
	m:ParseDiff(path)
	m:SanitizeCVars()
	local file = io.open(OUT_FILE, "w+")
	for _, section in pairs(api_order) do
		local info = m.ApiTypes[section]
		file:write(m:GetWikiTable(info, section))
	end
end

main()
print("done")
