local util = require("wowdoc")
local Path = require("path")
-- local parser = require("Util/wowtoolsparser")
local wago_csv = require("wowdoc.wago")
local output = "KethoWowpedia/patch/%s.lua"

util:MakeDir("KethoWowpedia/patch")

local m = {}

-- builds that wow.tools possibly has but would get overridden by a missing wago build (404 Not Found)
local missingWagoBuilds = {
	["6.0.2"] = true, -- 6.0.2.19034
	["6.0.3"] = true, -- 6.0.3.19342
	["6.1.0"] = true, -- 6.1.0.19702
	["6.1.2"] = true, -- 6.1.2.19865
	["6.2.0"] = true, -- 6.2.0.20338
	["6.2.2"] = true, -- 6.2.2.20574
	["6.2.3"] = true, -- 6.2.3.20886
	["6.2.4"] = true, -- 6.2.4.21742
	["7.0.3"] = true, -- 7.0.3.22810
	["7.1.0"] = true, -- 7.1.0.23222
	["7.1.5"] = true, -- 7.1.5.23420
	["7.2.0"] = true, -- 7.2.0.24015
	["7.2.5"] = true, -- 7.2.5.24742
	["7.3.0"] = true, -- 7.3.0.25195
	["7.3.2"] = true, -- 7.3.2.25549
}

function m:GetPatchData(name, options)
	local patches = wago_csv:GetPatches(options.flavor)
	for build in pairs(missingWagoBuilds) do
		patches[build] = nil
	end
	if options.flavor == "mainline" then
		-- just scan the whole folder for any missing retail builds
		local folder = Path.join("cache_csv", name)
		for fileName in lfs.dir(folder) do
			local major = util:GetPatchVersion(fileName)
			if major and not patches[major] and not util:IsClassicVersion(major) then
				local build = fileName:match("%d+%.%d+%.%d+%.%d+")
				print("adding", build)
				table.insert(patches, build)
			end
		end
	end
	local patches_sorted = util:ToList(patches, options.sort)
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
