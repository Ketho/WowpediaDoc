-- https://wowpedia.fandom.com/wiki/Module:API_info/elink/api
local Util = require("Util/Util")
local api_get = require("Scribunto/API_info/elink/api_get")

local BRANCH = "mainline_beta"
local ApiDoc = api_get:main(BRANCH)
local OUT = "out/lua/API_info.elink.api.lua"

local function main()
	local doc, non_doc = table.unpack(ApiDoc)
	local full = Util:CombineTable(doc, non_doc)
	print("writing", OUT)
	local file = io.open(OUT, "w")
	file:write('local data = {\n')
	for _, name in pairs(Util:SortTable(full)) do
		if doc[name] then
			file:write(string.format('\t["%s"] = "%s",\n', name, doc[name]))
		end
	end
	file:write("}\n\nreturn data\n")
	file:close()
end

main()
print("done")
