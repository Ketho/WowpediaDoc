local Util = require("Util/Util")
local Path = require "path"
-- local parser = require("Util/wowtoolsparser")
local wago_csv = require("Util/wago_csv")
local output = "KethoWowpedia/patch/%s.lua"

Util:MakeDir("KethoWowpedia/patch")

local m = {}

local needsWowToolsData = {
	battlepetspecies = true,
	chartitles = true,
	faction = true,	-- wago starts at 7.3.5.26972; 7.3.0.25195 and 7.3.2.25549 are returned from wago versions but not downloadable
	map = true,
	mount = true,
}

function m:GetPatchData(name, options)
	local patches = wago_csv:GetPatches(options.flavor)
	if options.flavor == "mainline" and needsWowToolsData[name] then
		-- just scan the whole folder for any missing retail builds
		local folder = Path.join("cache_csv", name)
		for fileName in lfs.dir(folder) do
			local major = Util:GetPatchVersion(fileName)
			if major and not patches[major] and not Util:IsClassicVersion(major) then
				local build = fileName:match("%d+%.%d+%.%d+%.%d+")
				table.insert(patches, build)
				print("adding", major, build)
			end
		end
	end
	local patches_sorted = Util:ToList(patches, options.sort)
	local t = {}
	for _, patch in pairs(patches_sorted) do
		local iter = wago_csv:ReadCSV(name, {header = true, build = patch})
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
