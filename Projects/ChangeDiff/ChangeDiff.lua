-- compares framexml versions
local lfs = require "lfs"
local Util = require("Util/Util")
local apidoc_nontoc = require("Util/apidoc_nontoc")

ChangeDiff = {}
require("Projects/ChangeDiff/Compare")
local m = ChangeDiff

m.apiTypes = {
	Function = {
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
	Event = {
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
	Structure = {
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
m.apiType_order = {"Function", "Event", "Structure"}

function m:LoadFrameXML(versions)
	local t = {}
	for _, version in pairs(versions) do
		t[version] = {}
		local path = "FrameXML/retail/%s/Blizzard_APIDocumentation"
		local docs = apidoc_nontoc:LoadBlizzardDocs(path:format(version))
		for apiType, apiTable in pairs(self.apiTypes) do
			local map = apiTable.map(docs)
			t[version][apiType] = map
		end
	end
	return t
end

local function main(view, versions)
	local framexml = m:LoadFrameXML(versions)
	local changes = m:CompareVersions(versions, framexml)
	require("Projects/ChangeDiff/Views/"..view):PrintView(changes)
end

-- main("PlainText", {"9.1.5.42010", "9.2.0.42538"})
main("PlainText", {"9.2.0.43340", "9.2.5.43903"})
print("done")
