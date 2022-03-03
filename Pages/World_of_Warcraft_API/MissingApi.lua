local Util = require("Util/Util")
local WikiText = require("Pages/World_of_Warcraft_API/WikiText")
Util:MakeDir("cache_lua")

local m = {}

local ignoredTags = {
	DEPRECATED = true,
	UI = true,
	Lua = true,
}

function m:ParseWikitext(wikitext)
	local api_names, tag_data = {}, {}
	for s1, name in string.gmatch(wikitext, "\n:(.-)%[API (.-)|") do
		table.insert(api_names, name) -- allow finding duplicates
		local tag = s1:match("<small>(.-)</small>")
		if tag then
			tag_data[name] = tag
		end
	end
	return api_names, tag_data
end

function m:GetGlobalApi()
	local global_api = Util:DownloadAndRun(
		"cache_lua/GlobalAPI.lua",
		"https://raw.githubusercontent.com/Ketho/BlizzardInterfaceResources/mainline/Resources/GlobalAPI.lua"
	)
	return Util:ToMap(global_api[1])
end

function m:FindDuplicates(wowpedia)
	print("-- duplicates")
	local t = {}
	for _, v in pairs(wowpedia) do
		if t[v] then
			print(v)
		else
			t[v] = true
		end
	end
end

function m:HasIgnoredTag(str)
	local tags = Util:strsplit(str, ", ")
	for _, tag in pairs(tags) do
		if ignoredTags[tag] then
			return true
		end
	end
end

function m:FindMissing(wowpedia, wowpedia_tags, global_api)
	local map = Util:ToMap(wowpedia)
	print("\n-- to add")
	for _, k in pairs(Util:SortTable(global_api)) do
		if not map[k] then
			print(k)
		end
	end
	print("\n-- to remove")
	table.sort(wowpedia)
	for _, k in pairs(wowpedia) do
		local hasIgnoredTag = wowpedia_tags[k] and self:HasIgnoredTag(wowpedia_tags[k])
		if not global_api[k] and not hasIgnoredTag then
			print(k)
		end
	end
end

function m:SaveWowpediaExport(path)
	local url = "https://wowpedia.fandom.com/wiki/Special:Export"
	local requestBody = "pages=World_of_Warcraft_API&curonly=1"
	Util:DownloadFilePost(path, url, requestBody)
end

local function main()
	WikiText:SaveExport()
	local text = WikiText:GetWikitext(true)
	local api, tags = m:ParseWikitext(text)
	m:FindDuplicates(api)
	local global_api = m:GetGlobalApi()
	m:FindMissing(api, tags, global_api)
end

main()
print("done")
