local Util = require("Util/Util")
local parser = require("Util/wowtoolsparser")
local output = "KethoWowpedia/patch/%s.lua"

Util:MakeDir("KethoWowpedia/patch")

local m = {}

local classic_flavors = {
	vanilla = true,
	wrath = true,
}

local missingHeaders = {
	-- ["3.4.1"] = true,
}

function m:GetPatchData(name, options)
	Util:MakeDir(parser.CACHE_PATH..name)
	local versions = parser:GetVersions(name)
	local patches, found = {}, {}
	for _, v in pairs(versions) do
		local major = Util:GetPatchVersion(v)
		local flavorFilter = (Util:IsClassicVersion(major) == (options.flavor ~= "mainline"))
		if not found[major] and flavorFilter and not missingHeaders[major] then
			found[major] = true -- only check for each major version and skip minor builds
			table.insert(patches, v)
		end
	end
	table.sort(patches, options.sort)
	local t = {}
	for _, patch in pairs(patches) do
		local iter = parser:ReadCSV(name, {header = true, build = patch})
		if iter then
			for l in iter:lines() do
				local ID = tonumber(l.ID)
				if ID and not t[ID] then
					t[ID] = {
						l = l,
						patch = patch,
					}
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

return m
