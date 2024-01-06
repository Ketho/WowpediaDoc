local lfs = require "lfs"
local PATH = require "path"
local Util = require("Util/Util")
local apidoc_nontoc = require("Util/apidoc_nontoc")

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

local function GetSubfolder(parent, name)
	local path = PATH.join(parent, name)
	if PATH.exists(path) then
		return path
	end
end

-- folder structure can vary
local function FindApiDocFolder(path)
	path = GetSubfolder(path, "Interface") or path
	path = GetSubfolder(path, "AddOns") or path
	path = GetSubfolder(path, "Blizzard_APIDocumentationGenerated") or path
	path = GetSubfolder(path, "Blizzard_APIDocumentation") or path
	if path:find("Blizzard_APIDocumentation") then
		return path
	end
end

local m = {}

function m:GetDocEvents(info)
	local t = {}
	for folder in lfs.dir(info.input) do
		if not Util.RelativePath[folder] then
			local path = FindApiDocFolder(PATH.join(info.input, folder))
			if path then
				local version = folder:match("%d+%.%d+.%d+")
				local build = folder:match("%((%d+)%)$") or folder:match("%d+$")
				-- Blizzard_APIDocumentation did not have events until patch 8.0
				if not version:find("^7%.") then
					local apiDocs = apidoc_nontoc:LoadBlizzardDocs(path)
					-- sort this by build later
					t[build] = {version, GetEventMap(apiDocs)}
				end
			end
		end
	end
	return t
end

-- apparently this goes through all patches of both classic and retail
function m:GetPatchData(tbl)
	local added, removed = {}, {}
	for _, build in pairs(Util:SortTable(tbl)) do
		local v = tbl[build]
		local version, data = table.unpack(v)
		for name in pairs(data) do
			if not added[name] then
				added[name] = version
			end
		end
		for name in pairs(added) do
			if not data[name] and not removed[name] then
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
	local data = {
		classic = self:GetData(flavors.classic),
		mainline = self:GetData(flavors.mainline),
	}
	return data
end

return m
