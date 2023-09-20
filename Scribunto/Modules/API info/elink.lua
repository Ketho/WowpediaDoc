local bit = require "bit32"
local data = {}
local wowprog_data = mw.loadData("Module:API_info/wowprog/api")
local m = {}

local api_types = {
	a = "api",
	e = "event",
}

local function GetApiBaseName(v)
	if v:find("%.") then
		v = v:match(".-%.(.+)")
	end
	return v
end

local links = {
	-- {
	-- 	id = "tly_globewut",
	-- 	label = "<s>Globe wut</s>",
	-- 	icon = "Townlong-Yak_Globe.png",
	-- 	url = "https://www.townlong-yak.com/globe/wut/#q:%s",
	-- 	show = function() return true end,
	-- },
	{
		id = "tly_apidocs",
		label = "Townlong Yak",
		icon = "Townlong-Yak_BAD.png",
		url = "https://www.townlong-yak.com/framexml/latest/Blizzard_APIDocumentation#%s",
		show = function(apiType, name)
			return data[apiType][name]
		end,
	},
	{
		id = "gh_apidocs",
		label = "Blizzard Docs",
		icon = "GitHub_Octocat.png",
		url = "https://github.com/search?q=repo:Gethe/wow-ui-source+\\%%22%s\\%%22+path:/^Interface\\/AddOns\\/Blizzard_APIDocumentationGenerated\\//&type=code",
		url_params = function(_, name)
			return GetApiBaseName(name)
		end,
		show = function(apiType, name)
			return data[apiType][name]
		end,
	},
	{
		id = "gh_wowapiweb",
		label = "Offline /api",
		icon = "ProfIcons_engineering.png",
		url = "https://mrbuds.github.io/wow-api-web/?search=%s",
		show = function(apiType, name)
			return data[apiType][name]
		end,
		url_params = function(apiType, name)
			if apiType == "a" then
				local apiName = GetApiBaseName(name)
				local system = data.a[name]
				return string.format("api:%s:%s:%s", "function", apiName, system)
			elseif apiType == "e" then
				local info = data.e[name]
				if info then
					return string.format("api:%s:%s:%s", "event", info.Name, info.System)
				end
			end
		end,
	},
	{
		id = "wowprog",
		label = "Wowprogramming",
		icon = "Wowprogramming.png",
		url = "https://wowprogramming.com/docs/api/%s.html",
		show = function(_, name) return wowprog_data[name] end,
	},
}

function m:GetElinks(apiType, name)
	if api_types[apiType] then
		data[apiType] = mw.loadData("Module:API_info/elink/"..api_types[apiType])
	end
	local t = {}
	for _, info in pairs(links) do
		if info.show(apiType, name) then
			local params = info.url_params and info.url_params(apiType, name) or name
			table.insert(t, {
				icon = info.icon,
				url = info.url:format(params),
				text = info.label,
				fs = "[[File:$icon|$iconsize px|link=$url]] &nbsp;[$url $text]"
			})
		end
	end
	return t
end

return m
