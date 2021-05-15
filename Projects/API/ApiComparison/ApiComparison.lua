local Util = require("Util/Util")
local path = "cache/GlobalAPI_%s.lua"
local url = "https://raw.githubusercontent.com/Ketho/BlizzardInterfaceResources/%s/Resources/GlobalAPI.lua"

local branches = {
	"live",
	"classic",
	"classic_beta",
}

-- avoid using templates as that increases page processing time
local wp_icons = {
	live = "[[File:Shadowlands-Logo-Small.png|34px|link=]]",
	bcc = "[[File:Bc icon.gif|link=]]",
	classic = "[[File:WoW Icon update.png|link=]]",
}

local apiNames = {}
local combinedApi = {}

local function ToMap(tbl)
	local t = {}
	for _, v in pairs(tbl) do
		t[v] = true
	end
	return t
end

for _, branch in pairs(branches) do
	local filePath = path:format(branch)
	Util:CacheFile(filePath, url:format(branch))
	local globalApi = require(filePath:gsub("%.lua", ""))[1]
	apiNames[branch] = ToMap(globalApi)
	for _, v in pairs(globalApi) do
		combinedApi[v] = true
	end
end

local sections = {
	bcc = {label = "BCC only", data = {}},
	classic = {label = "Classic only", data = {}},
	both = {label = "BCC & Classic", data = {}},

	retail_bcc = {label = "Retail & BCC", data = {}},
	retail_classic = {label = "Retail & Classic", data = {}},
	retail_both = {label = "Retail & BCC & Classic", data = {}},
}

local sectionOrder = {
	"bcc", "classic", "both",
	"retail_bcc", "retail_classic", "retail_both"
}

for _, name in pairs(Util:SortTable(combinedApi)) do
	local retail = apiNames.live[name]
	local bcc = apiNames.classic_beta[name]
	local classic = apiNames.classic[name]

	if retail then
		if bcc and classic then
			sections.retail_both.data[name] = true
		elseif bcc then
			sections.retail_bcc.data[name] = true
		elseif classic then
			sections.retail_classic.data[name] = true
		end
	else
		if bcc and classic then
			sections.both.data[name] = true
		elseif bcc then
			sections.bcc.data[name] = true
		elseif classic then
			sections.classic.data[name] = true
		end
	end
end

local file = io.open("out/lua/ApiCompare.txt", "w")
file:write('{| class="sortable darktable zebra"\n')
file:write('! !! !! !! align="left" | API Name\n')

local sectionfs = '|-\n! colspan="4" style="text-align:left; padding-left: 9em;" | %s \n'
local fs = "|-\n| %s || %s || %s || [[API %s|%s]]\n"

for _, tbl in pairs(sectionOrder) do
	file:write(sectionfs:format(sections[tbl].label))
	for _, name in pairs(Util:SortTable(sections[tbl].data)) do
		local retail = apiNames.live[name] and wp_icons.live or ""
		local bcc = apiNames.classic_beta[name] and wp_icons.bcc or ""
		local classic = apiNames.classic[name] and wp_icons.classic or ""
		file:write(fs:format(retail, bcc, classic, name, name))
	end
end

file:write("|}\n")
file:close()
print("done")
