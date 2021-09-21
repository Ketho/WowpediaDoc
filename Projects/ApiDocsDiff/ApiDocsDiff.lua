local lfs = require "lfs"
local Util = require("Util/Util")
local apidoc = require("Util/apidoc_nontoc")

-- local DEBUG = true
local fs = "FrameXML/retail/%s/Blizzard_APIDocumentation"

local apiTypes = {
	Functions = {
		map = function(tbl)
			local t = {}
			for _, system in pairs(tbl) do
				for _, apiTable in pairs(system.Functions or {}) do
					if system.Namespace then
						local fullName = string.format("%s.%s", system.Namespace, apiTable.Name)
						t[fullName] = apiTable
					else
						t[apiTable.Name] = apiTable
					end
				end
			end
			return t
		end,
		params = {"Arguments", "Returns"},
	},
	Events = {
		map = function(tbl)
			local t = {}
			for _, system in pairs(tbl) do
				for _, apiTable in pairs(system.Events or {}) do
					t[apiTable.LiteralName] = apiTable
				end
			end
			return t
		end,
		params = {"Payload"},
	},
	Tables = {
		map = function(tbl)
			local t = {}
			for _, system in pairs(tbl) do
				for _, apiTable in pairs(system.Tables or {}) do
					t[apiTable.Name] = apiTable
				end
			end
			return t
		end,
		params = {"Fields"},
	},
}

local apiType_order = {"Functions", "Events", "Tables"}

local function Print(...)
	if DEBUG then
		print(...)
	end
end

local m = {}

function m:main()
	local versions = self:GetApiDocVersions("FrameXML/retail")
	local framexml = self:LoadFrameXML(versions)
	-- self:CompareVersions(framexml, "9.0.5.38556", "9.1.0.40000")
	-- self:CompareVersions(framexml, "9.1.0.40000", "9.1.5.40071")
	-- self:CompareVersions(framexml, "9.0.1.36577", "9.1.5.40071")

	local apiHistory, paramHistory = self:GetHistory(versions, framexml)
	self:GetChangelog(apiHistory, paramHistory, "StatusBarWidgetVisualizationInfo")
end

function m:GetApiDocVersions(path)
	local t = {}
	for folder in lfs.dir(path) do
		local apidocs = string.format("%s/%s/%s", path, folder, "Blizzard_APIDocumentation")
		if lfs.attributes(apidocs) then
			t[folder] = true
		end
	end
	return t
end

function m:LoadFrameXML(versions)
	local t = {}
	for version in pairs(versions) do
		t[version] = {}
		local docs = apidoc:LoadBlizzardDocs(fs:format(version))
		for apiType, apiTable in pairs(apiTypes) do
			local map = apiTable.map(docs)
			t[version][apiType] = map
		end
	end
	return t
end

function m:CompareVersions(tbl, a, b)
	Print(string.format("Comparing %s to %s ", a, b))
	for _, apiType in pairs(apiType_order) do
		Print("* "..apiType)
		local left = tbl[a][apiType]
		local right = tbl[b][apiType]
		local paramTblNames = apiTypes[apiType].params
		self:CompareApiTables(left, right, paramTblNames)
	end
end

-- also returns a table but dont have any use for it, this might be unnecessarily complicated
function m:CompareApiTables(a, b, paramTblNames)
	local t = {
		added = {},
		removed = {},
		modified = {},
	}
	for _, name in pairs(Util:SortTable(b)) do
		if not a[name] then
			t.added[name] = true
			Print("+", name)
		end
	end
	for _, name in pairs(Util:SortTable(a)) do
		if not b[name] then
			t.removed[name] = true
			Print("-", name)
		end
	end
	for _, name in pairs(Util:SortTable(b)) do
		if a[name] and b[name] then
			for _, paramTblName in pairs(paramTblNames) do
				local leftParam, rightParam = a[name][paramTblName], b[name][paramTblName]
				local diff = self:GetStructureDiff(leftParam, rightParam)
				if #diff > 0 then
					t.modified[name] = diff
					Print("#", name)
					if #paramTblNames > 1 then
						Print("", "# "..paramTblName)
					end
					for _, param in pairs(diff) do
						Print("", param[1], param[2])
					end
				end
			end
		end
	end
	return t
end

function m:GetStructureDiff(a, b)
	local diff = {}
	local left, right = {}, {}
	-- structure was added
	if not a and b then
		for _, param in pairs(b) do
			table.insert(right, {"+", param.Name})
			Print("", "+++")
		end
	-- structure was removed
	elseif a and not b then
		for _, param in pairs(a) do
			table.insert(left, {"-", param.Name})
			Print("", "---")
		end
	-- structure is possibly modified
	elseif a and b then
		for _, param in pairs(a) do
			left[param.Name] = true
		end
		for _, param in pairs(b) do
			right[param.Name] = true
		end
	end
	for name in pairs(left) do
		if not right[name] then
			table.insert(diff, {"-", name})
		end
	end
	for name in pairs(right) do
		if not left[name] then
			table.insert(diff, {"+", name})
		end
	end
	return diff
end

local function SortParamBuild(a, b)
	local build_a = a.value:match("(%d+)$")
	local build_b = b.value:match("(%d+)$")
	if build_a ~= build_b then
		return build_a < build_b
	else
		return a.key < b.key
	end
end

local function SortReverse(a, b)
	return a > b
end

-- should refactor this maybe as not even I can read this
function m:GetHistory(builds, framexml_data)
	local builds_sorted = {}
	for build in pairs(builds) do
		table.insert(builds_sorted, build)
	end
	table.sort(builds_sorted, function(a, b)
		local build_a = a:match("(%d+)$")
		local build_b = b:match("(%d+)$")
		return build_a < build_b
	end)
	local apiHistory = {
		Functions = {},
		Events = {},
		Tables = {},
	}
	local paramHistory = {}
	for _, build in pairs(builds_sorted) do
		local framexml = framexml_data[build]
		for apiType, apiTable in pairs(framexml) do
			for name, paramTbl in pairs(apiTable) do
				apiHistory[apiType][name] = apiHistory[apiType][name] or {}
				local apiHistoryKey = apiHistory[apiType][name]
				if not apiHistoryKey.build then
					apiHistoryKey.build = build
				end
				paramHistory[name] = paramHistory[name] or {}
				for _, paramTblName in pairs(apiTypes[apiType].params) do
					for k, v in pairs(paramTbl[paramTblName] or {}) do
						if not paramHistory[name][v.Name] then
							-- doesnt discern between function arguments/returns
							paramHistory[name][v.Name] = build
						end
					end
				end
			end
		end
	end
	for _, apiType in pairs(apiType_order) do
		local apiTable = apiHistory[apiType]
		Print("\n-- "..apiType)
		for _, name in pairs(Util:SortTable(apiTable)) do
			local build = apiTable[name].build
			Print(build, name)
			for _, tbl in pairs(Util:SortTableCustom(paramHistory[name], SortParamBuild)) do
				local paramName = tbl.key
				local paramBuild = tbl.value
				if paramBuild ~= build then -- only show updated fields
					Print("", paramBuild, paramName)
				end
			end
		end
	end
	return apiHistory, paramHistory
end

local patch_fs = "* {{Patch %s|note=Added <code>%s</code>}}"

-- quick output example
function m:GetChangelog(apiHistory, paramHistory, name)
	print("==Patch changes==")
	local t = {}
	for k, v in pairs(paramHistory[name]) do
		-- print(k, v)
		t[v] = t[v] or {}
		table.insert(t[v], k)
	end
	for _, k in pairs(Util:SortTable(t, SortReverse)) do
		local v = t[k]
		table.sort(t[k])
		local patch = k:match("%d+%.%d+%.%d+")
		print(patch_fs:format(patch, table.concat(t[k], ", ")))
	end
end

m:main()
Print("done")
