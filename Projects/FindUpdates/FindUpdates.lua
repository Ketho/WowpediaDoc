local Util = require("Util/Util")
local apidoc = require("Util/apidoc_nontoc")

local fs = "FrameXML/retail/%s/Blizzard_APIDocumentation"

local apiTypes = {
	Functions = {
		map = function(tbl)
			local t = {}
			for _, system in pairs(tbl) do
				for _, func in pairs(system.Functions or {}) do
					if system.Namespace then
						local fullName = string.format("%s.%s", system.Namespace, func.Name)
						t[fullName] = true
					else
						t[func.Name] = true
					end
				end
			end
			return t
		end,
	},
	Events = {
		map = function(tbl)
			local t = {}
			for _, system in pairs(tbl) do
				for _, event in pairs(system.Events or {}) do
					t[event.LiteralName] = true
				end
			end
			return t
		end,
	},
	Tables = {
		map = function(tbl)
			local t = {}
			for _, system in pairs(tbl) do
				for _, structure in pairs(system.Tables or {}) do
					t[structure.Name] = structure
				end
			end
			return t
		end,
	},
}

local apiType_order = {"Functions", "Events", "Tables"}

local m = {}

function m:main()
	local versions = self:GetApiDocVersions("FrameXML/retail")
	local framexml = self:LoadFrameXML(versions)
	-- self:CompareVersions(framexml, "9.0.5.38556", "9.1.0.40000")
	-- self:CompareVersions(framexml, "9.1.0.40000", "9.1.5.40071")
	self:CompareVersions(framexml, "9.0.5.38556", "9.1.5.40071")
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
		print("# "..apiType)
		self:CompareApiTypes(tbl[a][apiType], tbl[b][apiType])
	end
end

function m:CompareApiTypes(a, b)
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
end

m:main()
