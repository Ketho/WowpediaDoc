local lfs = require "lfs"
local cjson = require "cjson"
local cjsonutil = require "cjson.util"
local Util = require("Util/Util")
local print_table = require("Util/print_table")

Util:MakeDir("cache_wut")
local url = "https://www.townlong-yak.com/globe/api/wut-symbol?q=%s"

local function WutRequest(folder, search)
	local path = string.format("cache_wut/%s/%s.json", folder, search)
	local success = Util:DownloadFilePost(path, url:format(search), "", false)
	if success or lfs.attributes(path) then
		local json = cjsonutil.file_load(path)
		local tbl = cjson.decode(json)
		return tbl
	end
end

local sources = {
	GlobalAPI = function()
		local tbl = Util:DownloadAndRun(
			"cache_lua/GlobalAPI.lua",
			"https://raw.githubusercontent.com/Ketho/BlizzardInterfaceResources/mainline/Resources/GlobalAPI.lua"
		)
		return tbl[1]
	end,
	Templates = function()
		local tbl = Util:DownloadAndRun(
			"cache_lua/Templates.lua",
			"https://raw.githubusercontent.com/Ketho/BlizzardInterfaceResources/mainline/Resources/Templates.lua"
		)
		return tbl
	end,
	Mixins = function()
		local tbl = Util:DownloadAndRun(
			"cache_lua/Mixins.lua",
			"https://raw.githubusercontent.com/Ketho/BlizzardInterfaceResources/mainline/Resources/Mixins.lua"
		)
		return tbl
	end,
}

local function main(apiType)
	local start = os.time()
	Util:MakeDir("cache_wut/"..apiType)
	local t = {}
	local resource = sources[apiType]()
	for _, name in pairs(resource) do
	-- for name in pairs(resource) do
		-- print(name)
		local results = WutRequest(apiType, name)
		local count = 0
		if results then
			-- print_table(results)
			for _, v in pairs(results.a) do
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
	local fs = "%s,%s"
	for _, tbl in pairs(Util:SortTableCustom(t, sortfunc)) do
		print(fs:format(tbl.value, tbl.key))
	end
	print("took "..elapsed.." seconds")
end

-- main("GlobalAPI")
-- main("Templates")
main("Mixins")
print("done")
