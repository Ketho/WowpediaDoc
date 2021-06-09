-- https://wowpedia.fandom.com/wiki/Module:API_info/api_doc
local Util = require("Util/Util")
local ApiDoc = require("Scribunto/API_info/api_doc_get")

local OUT = "out/lua/API_info.apidoc.lua"

local api_flags = {
	undocumented = 0x1,
	documented = 0x2,
}

local m = {}

function m:main()
	local doc, non_doc = table.unpack(ApiDoc)
	local full = Util:CombineTable(doc, non_doc)
	for name in pairs(full) do
		local flag1 = non_doc[name] and api_flags.undocumented or 0
		local flag2 = doc[name] and api_flags.documented or 0
		full[name] = flag1 | flag2
	end

	local file = io.open(OUT, "w")
	file:write('local data = {\n')
	for _, name in pairs(Util:SortTable(full)) do
		local flags = full[name]
		local values = string.format("flags = 0x%X", flags)
		if doc[name] then
			values = values..', system = "'..doc[name]..'"'
		end
		file:write(string.format('\t["%s"] = {%s},\n', name, values))
	end
	file:write("}\n\nreturn data\n")
	file:close()
end

m:main()
print("done")
