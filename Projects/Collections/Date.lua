local Util = require("Util/Util")
local parser = require("Util/wowtoolsparser")

Util:MakeDir("KethoWowpedia/date")

local builds = {
	"7.3.5",
	"8.0.1",
	"8.1.0",
	"8.1.5",
	"8.2.0",
	"8.2.5",
	"8.3.0",
	"9.0.1",
	"9.0.2",
	"9.0.5",
	"9.1.0",
}

local function GetCollectionsDate(dbc)
	local firstSeen = {}

	for _, build in pairs(builds) do
		local iter = parser.ReadCSV(dbc, {header = true, build = build})
		for l in iter:lines() do
			local ID = tonumber(l.ID)
			if ID and not firstSeen[ID] then
				firstSeen[ID] = build
			end
		end
	end

	for id, build in pairs(firstSeen) do
		if build == builds[1] then
			firstSeen[id] = nil
		end
	end

	local file = io.open(string.format("KethoWowpedia/date/%s.lua", dbc), "w")
	file:write(string.format("KethoWowpedia.date.%s = {\n", dbc))
	local fs = '\t[%d] = "%s",\n'
	for _, k in pairs(Util:ProxySort(firstSeen)) do
		file:write(fs:format(k, firstSeen[k]))
	end
	file:write("}\n")
	file:close()
end

GetCollectionsDate("mount")
GetCollectionsDate("battlepetspecies")
GetCollectionsDate("toy")
