-- queries townlong yak wut and writes tp csv with api sorted by popularity
local lfs = require("lfs")
local cjson = require "cjson"
local cjsonutil = require "cjson.util"
local util = require("util")
-- local print_table = require("Util/print_table")

util:MakeDir("cache_wut")
local wut_url = "https://www.townlong-yak.com/globe/api/wut-symbol?q=%s"
local github_url = "https://raw.githubusercontent.com/Ketho/BlizzardInterfaceResources/mainline/Resources/%s.lua"

local function WutRequest(folder, search)
	local path = string.format("cache_wut/%s/%s.json", folder, search)
	util:DownloadFilePost(wut_url:format(search), path, "", false)
	if not lfs.attributes(path) then
		local file = io.open(path, "w")
		file:write([[{"a":{}}]]) -- create placeholder json to avoid further requests
		file:close()
	end
	local json = cjsonutil.file_load(path)
	local tbl = cjson.decode(json)
	return tbl
end

local sources = {
	GlobalAPI = function(name)
		local tbl = util:DownloadAndRun(
			string.format("cache_lua/%s.lua", name),
			github_url:format(name)
		)
		return tbl[1]
	end,
	Lua = function()
		local tbl = util:DownloadAndRun(
			string.format("cache_lua/%s.lua", "GlobalAPI"),
			github_url:format("GlobalAPI")
		)
		return tbl[2]
	end,
	Events = function(name)
		local tbl = util:DownloadAndRun(
			string.format("cache_lua/%s.lua", name),
			github_url:format(name)
		)
		local t = {}
		for _, namespace in pairs(tbl) do
			for _, event in pairs(namespace) do
				table.insert(t, event)
			end
		end
		table.sort(t)
		return t
	end,
	-- CVars = function(name)
	-- local tbl = util:DownloadAndRun(
	-- 	string.format("cache_lua/%s.lua", name),
	-- 	github_url:format(name)
	-- )
	-- 	return util:SortTable(tbl[1].var)
	-- end,
	FrameXML = function(name)
		local tbl = util:DownloadAndRun(
			string.format("cache_lua/%s.lua", name),
			github_url:format(name)
		)
		for _, v in pairs(tbl[2]) do
			table.insert(tbl[1], v)
		end
		return tbl[1]
	end,
	Frames = function(name)
		local tbl = util:DownloadAndRun(
			string.format("cache_lua/%s.lua", name),
			github_url:format(name)
		)
		return tbl[1]
	end,
	Templates = function(name)
		local tbl = util:DownloadAndRun(
			string.format("cache_lua/%s.lua", name),
			github_url:format(name)
		)
		return util:SortTable(tbl)
	end,
	Mixins = function(name)
		local tbl = util:DownloadAndRun(
			string.format("cache_lua/%s.lua", name),
			github_url:format(name)
		)
		return tbl
	end,
}

local function WriteResource(apiType)
	local start = os.time()
	util:MakeDir("cache_wut/"..apiType)
	local t = {}
	local resource = sources[apiType](apiType)
	for _, name in pairs(resource) do
		local results = WutRequest(apiType, name)
		local count = 0
		if results then
			-- print_table(results)
			for _ in pairs(results.a) do
				count = count + 1
			end
		end
		t[name] = count
	end
	local sortfunc = function(a, b)
		if a.value ~= b.value then
			return a.value > b.value
		else
			return a.key < b.key
		end
	end
	local elapsed = os.time() - start
	local fs = "%s,%s\n"
	local file = io.open(string.format("Projects/TownlongWut/%s.csv", apiType), "w")
	file:write("Count,Name\n")
	for _, tbl in pairs(util:SortTableCustom(t, sortfunc)) do
		file:write(fs:format(tbl.value, tbl.key))
	end
	file:close()
	print("-- written "..apiType.." in "..elapsed.." seconds")
end

local function main()
	for k in pairs(sources) do
		WriteResource(k)
	end
end

main()
print("done")
