local lfs = require "lfs"
local Util = require("Util/Util")
local apidoc_nontoc = require("Util/apidoc_nontoc")

local pre252_format = {
	["1.13.2"] = true,
	["1.13.3"] = true,
	["1.13.4"] = true,
	["1.13.5"] = true,
	["1.13.6"] = true,
	["1.13.7"] = true,
	["2.5.1"] = true,
}

local function GetEventMap(data)
	local t = {}
	for _, info in pairs(data) do
		if info.Events then
			for _, event in pairs(info.Events) do
				t[event.LiteralName] = true
			end
		end
	end
	return t
end

local m = {}

function m:GetDocEvents(info)
	local t = {}
	for folder in lfs.dir(info.input) do
		if not Util.RelativePath[folder] then
			local version = folder:match("%d+%.%d+.%d+")
			local path
			if info.id == "retail" then
				path = info.input.."/"..folder.."/Blizzard_APIDocumentation"
			elseif info.id == "classic" then
				if pre252_format[version] then
					path = info.input.."/"..folder.."/AddOns/Blizzard_APIDocumentation"
				else
					path = info.input.."/"..folder.."/Interface/AddOns/Blizzard_APIDocumentation"
				end
			end
			local apiDocs = apidoc_nontoc:LoadBlizzardDocs(path)
			t[version] = GetEventMap(apiDocs)
		end
	end
	return t
end

function m:GetPatchData(tbl)
	local added, removed = {}, {}
	for _, version in pairs(Util:SortTable(tbl)) do
		local v = tbl[version]
		for name in pairs(v) do
			if not added[name] then
				added[name] = version
			end
		end
		for name in pairs(added) do
			if not v[name] and not removed[name] then
				removed[name] = version
			end
		end
	end

	local t = {}
	for name, version in pairs(added) do
		t[name] = t[name] or {}
		if version == "8.0.1" then -- event docs were added in 8.0.1
			t[name][1] = false
		else
			t[name][1] = version
		end
	end
	for name, version in pairs(removed) do
		t[name] = t[name] or {}
		t[name][2] = version
	end
	return t
end

function m:GetData(info)
	local docEvents = self:GetDocEvents(info)
	local patchData = self:GetPatchData(docEvents)
	return patchData
end

function m:main(flavors)
	self:GetData(flavors.classic)
	local data = self:GetData(flavors.retail)
	return data
end

return m
