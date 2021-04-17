local Util = require("Util/Util")
local parser = require("Util/wowtoolsparser")
local output = "KethoWowpedia/patch/%s.lua"

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

local uimap_patches = {}
for k, v in pairs(patches) do
	uimap_patches[k] = v
end
table.remove(uimap_patches, 1) -- remove 7.3.5

local dbc = {
	mount = patches,
	battlepetspecies = patches,
	toy = patches,
	uimap = uimap_patches,
}

function m:GetFirstSeen(name)
	local t = {}
	local patchTbl = dbc[name] or patches
	for _, patch in pairs(patchTbl) do
		local iter = parser.ReadCSV(name, {header = true, build = patch})
		for l in iter:lines() do
			local ID = tonumber(l.ID)
			if ID and not t[ID] then
				t[ID] = patch
			end
		end
	end
	for id, patch in pairs(t) do
		if patch == patchTbl[1] then
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
	for name in pairs(dbc) do
		local data = self:GetFirstSeen(name)
		self:WriteData(data, output:format(name), tblName:format(name))
	end
end

return m
