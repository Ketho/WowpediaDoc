local lfs = require "lfs"
local Util = require("Util/Util")
local apidoc = require("Util/apidoc_nontoc")

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

local m = {}

function m:main()
	local versions = self:GetApiDocVersions("FrameXML/retail")
	local framexml = self:LoadFrameXML(versions)
	self:CompareVersions(framexml, "9.0.5.38556", "9.1.0.40000")
	-- self:CompareVersions(framexml, "9.1.0.40000", "9.1.5.40071")
	-- self:CompareVersions(framexml, "9.0.1.36577", "9.1.5.40071")
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
	print(string.format("Comparing %s to %s ", a, b))
	for _, apiType in pairs(apiType_order) do
		local left = tbl[a][apiType]
		local right = tbl[b][apiType]
		print("* "..apiType)
		local paramTblNames = apiTypes[apiType].params
		self:CompareApiTables(left, right, paramTblNames)
	end
end

function m:CompareApiTables(a, b, paramTblNames)
	for _, name in pairs(Util:SortTable(b)) do
		if not a[name] then
			print("+", name)
		end
	end
	for _, name in pairs(Util:SortTable(a)) do
		if not b[name] then
			print("-", name)
		end
	end
	for _, name in pairs(Util:SortTable(b)) do
		if a[name] and b[name] then
			for _, paramTblName in pairs(paramTblNames) do
				local leftParam, rightParam = a[name][paramTblName], b[name][paramTblName]
				if (leftParam and not rightParam) or (not leftParam and rightParam) then
					print("#!", name)
					print("", paramTblName)
				elseif leftParam and rightParam then
					local diff = self:CrappyTableEquals(leftParam, rightParam)
					if #diff > 0 then
						print("#", name)
						if #paramTblNames > 1 then
							print("", "# "..paramTblName)
						end
						for _, param in pairs(diff) do
							print("", param[1], param[2])
						end
					end
				end
			end
		end
	end
end

function m:CrappyTableEquals(a, b)
	local diff = {}
	local left, right = {}, {}
	for _, v in pairs(a) do
		left[v.Name] = true
	end
	for _, v in pairs(b) do
		right[v.Name] = true
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

m:main()
print("done")
