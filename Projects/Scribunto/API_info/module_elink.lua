-- https://wowpedia.fandom.com/wiki/Module:API_info/elink
-- https://github.com/Ketho/WowpediaApiDoc/blob/master/Projects/Scribunto/API_info/module_elink.lua
local bit = require "bit32"
local blizzdoc_data = mw.loadData("Module:API_info/blizzdoc")
local wowprog_data = mw.loadData("Module:API_info/wowprog")
local m = {}

local HTML_LIST_START = '<ul class="plainlinks elinks">\n'
local HTML_LIST_ITEM = [=[<li style="padding-left: 0px">[[Image:%s.png|16px|link=%s]] &nbsp;%s</li>
]=]
local HTML_LIST_END = '</ul>'

local wowapiwebType = {
	a = "function",
	e = "event",
}

local links = {
	{
		id = "gh_framexml",
		icon = "GitHub_Octocat",
		url = "https://github.com/Gethe/wow-ui-source/search?q=%s",
		text = "FrameXML",
		show = function() return true end,
	},
	{
		id = "tly_globewut",
		icon = "Townlong-Yak_Globe",
		url = "https://www.townlong-yak.com/globe/wut/#q:%s",
		text = "Globe Wut",
		show = function() return true end,
	},
	{
		id = "tly_apidocs",
		icon = "Townlong-Yak_BAD",
		url = "https://www.townlong-yak.com/framexml/latest/Blizzard_APIDocumentation#%s",
		text = "Blizzard Docs",
		show = function(v)
			local flags = blizzdoc_data[v].flags
			return bit.band(flags, 0x2) > 0
		end,
	},
	{
		id = "gh_wowapiweb",
		icon = "ProfIcons_engineering",
		url = "https://mrbuds.github.io/wow-api-web/?search=%s",
		text = "Offline /api",
		show = function(v)
			local flags = blizzdoc_data[v].flags
			return bit.band(flags, 0x2) > 0
		end,
	},
	{
		id = "wowprog",
		icon = "Wowprogramming",
		url = "https://wowprogramming.com/docs/api/%s.html",
		text = "Wowprogramming",
		show = function(v) return wowprog_data[v] end,
	},
}

-- omit namespace in headers
local function GetApiBaseName(v)
	if v:find("%.") then
		v = v:match(".-%.(.+)")
	end
	return v
end

local function GetSearchParams(name, data, info)
	local search
	-- github does not do exact searches with dots
	if info.id == "gh_framexml" then
		search = GetApiBaseName(name)
	elseif info.id == "gh_wowapiweb" then
		if data.system then
			local apiName = GetApiBaseName(name)
			search = string.format("api:%s:%s:%s", wowapiwebType.a, apiName, data.system)
		end
	else
		search = name
	end
	return search
end

local function GetElinkText(name, data)
	local s = HTML_LIST_START
	for _, info in pairs(links) do
		if info.show(name) then
			local search = GetSearchParams(name, data, info)
			local url = info.url:format(search)
			local link = string.format("[%s %s]", url, info.text)
			s = s..HTML_LIST_ITEM:format(info.icon, url, link)
		end
	end
	s = s..HTML_LIST_END
	return s
end

function m.GetElinks(name)
	local data = blizzdoc_data[name]
	if data then
		return GetElinkText(name, data)
	end
end

return m
