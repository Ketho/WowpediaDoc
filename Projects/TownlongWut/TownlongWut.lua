local cjson = require "cjson"
local lfs = require "lfs"
local cjsonutil = require "cjson.util"
local Util = require("Util/Util")
local print_table = require("Util/print_table")

local url = "https://www.townlong-yak.com/globe/api/wut-symbol?q=%s"

local function WutRequest(search)
    local path = string.format("cache_wut/%s.json", search)
	local success = Util:DownloadFilePost(path, url:format(search), "")
    if success or lfs.attributes(path) then
        local json = cjsonutil.file_load(path)
        local tbl = cjson.decode(json)
	    return tbl
    end
end

local function GetGlobalApi()
    local global_api = Util:DownloadAndRun(
        "cache_lua/GlobalAPI.lua",
        "https://raw.githubusercontent.com/Ketho/BlizzardInterfaceResources/mainline/Resources/GlobalAPI.lua"
    )
    return global_api[1]
end

local function main()
    local globalapi = GetGlobalApi()
    local t = {}
    local start = os.time()
    for _, name in pairs(globalapi) do
        local results = WutRequest(name)
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

main()
print("done")
