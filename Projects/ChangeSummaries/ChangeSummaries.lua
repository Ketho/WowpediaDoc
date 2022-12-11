-- https://wowpedia.fandom.com/wiki/API_change_summaries
local lfs = require "lfs"
local Util = require("Util/Util")
local cvar_module = require("Projects/ChangeSummaries/CVar")
local widget_module = require("Projects/ChangeSummaries/Widget")
local m = {}
local BRANCH = "mainline" -- for widgets, cvars
-- local DIFF = {"commit", "ptr_beta", false}
local DIFF = {"compare", "10.0.0..10.0.2", true}

local OUT_FILE = "out/page/ChangeSummaries.txt"
Util:MakeDir("cache_diff")
Util:MakeDir("cache_diff/commit")
Util:MakeDir("cache_diff/compare")

local function GetDiff()
	local path, url
	if DIFF[1] == "commit" then
		path = string.format("cache_diff/commit/%s.diff", DIFF[2])
		url = string.format("https://github.com/Ketho/BlizzardInterfaceResources/commit/%s.diff", DIFF[2])
	elseif DIFF[1] == "compare" then
		local fpath = DIFF[2]:gsub("%.%.", "__")
		path = string.format("cache_diff/compare/%s.diff", fpath)
		url = string.format("https://github.com/Ketho/BlizzardInterfaceResources/compare/%s.diff", DIFF[2])
	end
	local isCache = DIFF[3]
	Util:DownloadFile(path, url, isCache)
	return path
end

local data_table = {
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
		textfunc = function(name, line_number)
			local widget_object = widget_module:GetWidgetByLine(name, line_number)
			-- have to manually format any widget scripts
			return string.format(": {{api|t=w|%s:%s}}", widget_object, name)
		end,
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
		textfunc = function(name)
			local tt = cvar_module.main(BRANCH, name) or name
			return ": "..tt
		end,
		parseName = function(innerLine)
			return innerLine:match('\t\t%["(.+)"%]')
		end,
		class = "mw-customtoggle-cvars",
		id = "mw-customcollapsible-cvars",
	},
}

local api_order = {"GlobalAPI", "WidgetAPI", "Events", "CVars"}

for _, v in pairs(data_table) do
	v.changes = {
		["+"] = {},
		["-"] = {},
	}
end

function m:ParseDiff(diff_path)
	local file = io.open(diff_path, "r")
	local section
	for line in file:lines() do
		if line:find("^diff") then
			section = line:match("(%a+)%.lua")
		end
		if section ~= "WidgetAPI" then
			local isHeader = line:find("^%+%+%+ ") or line:find("^%-%-%- ")
			local sign, innerLine = line:match("^([%+%-])(.+)")
			if sign and not isHeader then
				local info = data_table[section]
				local name = info and info.parseName(innerLine)
				if name then
					local text
					if info.textfunc then
						text = info.textfunc(name)
					else
						text = info.text:format(name)
					end
					table.insert(info.changes[sign], text)
				end
			end
		end
	end
	file:close()
end

function m:GetWikiTable(info, section)
	-- need to sort events at least, and cvars
	if section ~= "WidgetAPI" then
		table.sort(info.changes["+"], Util.SortNocase)
		table.sort(info.changes["-"], Util.SortNocase)
	end
	local t = {}
	table.insert(t, string.format('==%s==', info.label or section))
	table.insert(t, '{| class="wikitable" style="min-width: 600px"')
	table.insert(t, string.format('|- class="%s"', info.class))
	table.insert(t, string.format('! style="width: 50%%" | <font color="lightgreen">Added</font> <small>(%d)</small>', #info.changes["+"]))
	table.insert(t, string.format('! style="width: 50%%" | <font color="pink">Removed</font> <small>(%d)</small>', #info.changes["-"]))
	table.insert(t, string.format('|- class="mw-collapsible" id="%s"', info.id))
	table.insert(t, '| valign="top" | <div style="margin-left:-1.5em">')
	for _, v in pairs(info.changes["+"]) do
		table.insert(t, v)
	end
	table.insert(t, '</div>')
	table.insert(t, '| valign="top" | <div style="margin-left:-1.5em">')
	for _, v in pairs(info.changes["-"]) do
		table.insert(t, v)
	end
	table.insert(t, '</div>\n|}\n\n')
	return table.concat(t, "\n")
end

local function main()
	local path = GetDiff()
	m:ParseDiff(path) -- fill changes tbl
	widget_module.main(data_table.WidgetAPI, path, BRANCH)
	cvar_module:SanitizeCVars(data_table)

	print("writing", OUT_FILE)
	local file = io.open(OUT_FILE, "w+")
	for _, section in pairs(api_order) do
		local info = data_table[section]
		file:write(m:GetWikiTable(info, section))
	end
end

main()
print("done")
