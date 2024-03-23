-- https://wowpedia.fandom.com/wiki/Module:API_info/elink/event
local Util = require("Util/Util")
local BRANCH = "mainline"
Util:LoadLuaEnums(BRANCH)
local OUT = "out/lua/API_info.elink.event.lua"

local function main()
	Util:LoadDocumentation(BRANCH)
	table.sort(APIDocumentation.events, function(a, b)
		return a.LiteralName < b.LiteralName
	end)

	print("writing", OUT)
	local file = io.open(OUT, "w")
	file:write("-- https://github.com/Ketho/WowpediaDoc/blob/master/Scribunto/API_info/elink/event.lua\n")
	file:write('local data = {\n')
	for _, event in ipairs(APIDocumentation.events) do
		file:write(string.format('\t["%s"] = {Name = "%s", System = "%s"},\n',
			event.LiteralName, event.Name, event.System.Name))
	end
	file:write("}\n\nreturn data\n")
	file:close()
end

main()
