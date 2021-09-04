-- https://wowpedia.fandom.com/wiki/Module:API_info/elink/api
local Util = require("Util/Util")
local ApiDoc = require("Scribunto/API_info/elink/api_get")

local OUT = "out/lua/API_info.elink.api.lua"

local m = {}

function m:main()
	local doc, non_doc = table.unpack(ApiDoc)
	local full = Util:CombineTable(doc, non_doc)
	local file = io.open(OUT, "w")
	file:write('local data = {\n')
	for _, name in pairs(Util:SortTable(full)) do
		if doc[name] then
			file:write(string.format('\t["%s"] = {System = "%s"},\n', name, doc[name]))
		end
	end
	file:write("}\n\nreturn data\n")
	file:close()
end

m:main()
print("done")
