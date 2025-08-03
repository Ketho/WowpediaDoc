local util = require("wowdoc")
local products = require("wowdoc.products")
local WikiText = require("Pages/World of Warcraft API/WikiText")
util:MakeDir("cache_lua")

local PRODUCT = "wowxptr" ---@type TactProduct
util:LoadDocumentation(PRODUCT)
local _, blizres_branch = products:GetBranch(PRODUCT)

local Signatures_Parse = require("Pages/World of Warcraft API/Signatures_Parse")
local signatures = Signatures_Parse:GetSignatures()

local m = {}

local ignoredTags = {
	deprecated = true,
	framexml = true,
	lua = true,
}

function m:ParseWikitext(wikitext)
	local api_names, tag_data = {}, {}
	for line in string.gmatch(wikitext, "[^\r\n]+") do
		local name = line:match(": %[%[API (.-)|")
		local tag = line:match("{{apitag|(.-)}}")
		table.insert(api_names, name) -- allow finding duplicates
		if name and tag then
			tag_data[name] = tag
		end
	end
	return api_names, tag_data
end

function m:GetGlobalApi()
	local global_api = util:DownloadAndRun(
		string.format("https://raw.githubusercontent.com/Ketho/BlizzardInterfaceResources/%s/Resources/GlobalAPI.lua", blizres_branch),
		string.format("cache_lua/GlobalAPI_%s.lua", blizres_branch)
	)
	return util:ToMap(global_api[1])
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
	local tags = util:strsplit(str, ", ")
	for _, tag in pairs(tags) do
		if ignoredTags[tag] then
			return true
		end
	end
end

function m:FindMissing(wowpedia, wowpedia_tags, global_api)
	local map = util:ToMap(wowpedia)
	print("\n-- to add")
	for _, k in pairs(util:SortTable(global_api)) do
		if not map[k] then
			if signatures[k] then
				print(string.format(": %s", signatures[k]))
			else
				print(string.format(": [[API %s|%s]]()", k, k))
			end
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
