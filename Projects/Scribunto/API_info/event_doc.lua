-- https://wowpedia.fandom.com/wiki/Module:API_info/event_doc
local Util = require("Util/Util")
local OUT = "out/lua/API_info__eventdoc.lua"

local m = {}

function m:main()
	local FrameXML = require("Documenter/FrameXML/FrameXML")
	FrameXML:LoadApiDocs("Documenter/FrameXML")
	table.sort(APIDocumentation.events, function(a, b)
		return a.LiteralName < b.LiteralName
	end)

	local file = io.open(OUT, "w")
	file:write('local data = {\n')
	for _, event in ipairs(APIDocumentation.events) do
		file:write(string.format('\t["%s"] = {Name = "%s", System = "%s"},\n', event.LiteralName, event.Name, event.System.Name))
	end
	file:write("}\n\nreturn data\n")
	file:close()
end

m:main()
print("done")
