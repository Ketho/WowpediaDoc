local Util = require("Util/Util")
local parser = require("Util/wowtoolsparser")
local output = "KethoWowpedia/patch/%s.lua"

Util:MakeDir("KethoWowpedia/patch")

local m = {}

function m:GetPatchData(name, options)
	local versions = parser:GetVersions(name)
	local patches, found = {}, {}
	for _, v in pairs(versions) do
		local major = Util:GetPatchVersion(v)
		local flavorFilter = Util:IsClassicVersion(major) == (options.flavor == "classic")
		if not found[major] and flavorFilter then
			found[major] = true -- only check for each major version and skip minor builds
			table.insert(patches, v)
		end
	end
	return self:GetFirstSeen(name, patches, options)
end

function m:GetFirstSeen(name, patches, options)
	table.sort(patches, Util.SortBuild)
	local t = {}
	for _, patch in pairs(patches) do
		local iter = parser:ReadCSV(name, {header = true, build = patch})
		if iter then
			for l in iter:lines() do
				local ID = tonumber(l.ID)
				if ID and not t[ID] then
					t[ID] = patch
				end
			end
		end
	end
	-- for mainline we can't be sure of the first build for valid patch data, with some exceptions
	if options.flavor == "mainline" and options.initial ~= false then
		for id, patch in pairs(t) do
			if patch == patches[1] or (options.initial and patch:find(options.initial)) then
				t[id] = nil
			end
		end
	end
	return t
end

function m:WriteData(tbl, path, tblName)
	local file = io.open(path, "w")
	file:write(tblName)
	local fs = '\t[%d] = "%s",\n'
	for _, k in pairs(Util:SortTable(tbl)) do
		file:write(fs:format(k, tbl[k]))
	end
	file:write("}\n")
	file:close()
end

local patch_collections = {
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
	"9.1.5",
}

local patch_uimap = {}
for k, v in pairs(patch_collections) do
	patch_uimap[k] = v
end
table.remove(patch_uimap, 1) -- remove 7.3.5

local dbc = {
	mount = patch_collections,
	battlepetspecies = patch_collections,
	toy = patch_collections,
	uimap = patch_uimap,
}

function m:UpdateAddOn()
	local tblName = "KethoWowpedia.patch.%s = {\n"
	for name, patches in pairs(dbc) do
		local data = self:GetFirstSeen(name, patches)
		self:WriteData(data, output:format(name), tblName:format(name))
	end
end

return m
