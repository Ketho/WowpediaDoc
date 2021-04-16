local Util = require("Util/Util")
local parser = require("Util/wowtoolsparser")
local OUT = "KethoWowpedia/patch/%s.lua"

Util:MakeDir("KethoWowpedia/patch")

local m = {}

local patches = {
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

local dbc = {
	"mount",
	"battlepetspecies",
	"toy",
}

function m:GetFirstSeen(name)
	local t = {}
	for _, patch in pairs(patches) do
		local iter = parser.ReadCSV(name, {
			header = true,
			build = patch
		})
		for l in iter:lines() do
			local ID = tonumber(l.ID)
			if ID and not t[ID] then
				t[ID] = patch
			end
		end
	end
	for id, patch in pairs(t) do
		if patch == patches[1] then
			t[id] = nil
		end
	end
	return t
end

function m:WriteData(tbl, path, tblName)
	local file = io.open(path, "w")
	file:write(tblName)
	local fs = '\t[%d] = "%s",\n'
	for _, k in pairs(Util:ProxySort(tbl)) do
		file:write(fs:format(k, tbl[k]))
	end
	file:write("}\n")
	file:close()
end

function m:UpdateAddOn()
	local tblName = "KethoWowpedia.patch.%s = {\n"
	for _, name in pairs(dbc) do
		local data = self:GetFirstSeen(name)
		self:WriteData(data, OUT:format(name), tblName:format(name))
	end
end

return m
