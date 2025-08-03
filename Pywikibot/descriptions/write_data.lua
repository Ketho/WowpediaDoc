local util = require("wowdoc")
package.path = package.path..";../?.lua"
local updated_desc = require("wow-api-descriptions/updated")
local OUT = "Pywikibot/descriptions/data.py"

local fs = '\t"%s": "%s",\n'

local file = io.open(OUT, "w")
file:write("descriptions = {\n")
for _, k in pairs(util:SortTable(updated_desc)) do
	local v = updated_desc[k]:gsub([["]], [[\"]])
	file:write(fs:format(k, v))
end
file:write("}\n")
file:close()
