local xml = require "xml"
local Util = require "Util/Util"
Util:MakeDir("cache_lua")

local m = {}
local WIKIPAGE_PATH = "cache_lua/World_of_Warcraft_API.xml"

local ignoredTags = {
	DEPRECATED = true,
	UI = true,
	Lua = true,
}

function m:ParseWikitext(PATH)
	local file_string = io.open(PATH):read("a")
	-- could also just read the file by line instead of fancy xml
	local xml_data = xml.load(file_string)
	local wikitext = xml_data[2][4][8][1]
	local str_start = wikitext:find("== API Reference ==")
	local str_end = wikitext:find("== Classic ==")
	local retail_wikitext = wikitext:sub(str_start, str_end-1)

	local api_names, tag_data = {}, {}
	for s1, name in string.gmatch(retail_wikitext, "\n:(.-)%[API (.-)|") do
		table.insert(api_names, name) -- allow finding duplicates
		local tag = s1:match("<small>(.-)</small>")
		if tag then
			tag_data[name] = tag
		end
	end
	return api_names, tag_data
end

function m:GetGlobalApi()
	local api_path = "cache_lua/GlobalAPI.lua"
	local api_url = "https://raw.githubusercontent.com/Ketho/BlizzardInterfaceResources/mainline/Resources/GlobalAPI.lua"
	Util:DownloadFile(api_path, api_url)
	local api = require(api_path:gsub("%.lua", ""))
	local global_api = Util:ToMap(api[1])
	return global_api
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
	Util:CacheFilePost(path, url, requestBody)
end

local function main()
	m:SaveWowpediaExport(WIKIPAGE_PATH)
	local wowpedia_api, wowpedia_tags = m:ParseWikitext(WIKIPAGE_PATH)
	m:FindDuplicates(wowpedia_api)
	local global_api = m:GetGlobalApi()
	m:FindMissing(wowpedia_api, wowpedia_tags, global_api)
end

main()
