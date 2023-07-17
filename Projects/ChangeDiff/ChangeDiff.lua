-- compares framexml versions
local Util = require("Util/Util")
local apidoc_nontoc = require("Util/apidoc_nontoc")

local BRANCH = "mainline"
-- requires Constants.CharCustomizationConstants 
require("Documenter.LuaEnum"):main(BRANCH)

ChangeDiff = {}
require("Projects/ChangeDiff/Compare")
local m = ChangeDiff
local PrintView = require("Projects/ChangeDiff/PrintView")

m.apiTypes = {
	Function = {
		map = function(tbl)
			local t = {}
			for _, system in pairs(tbl) do
				if system.Type ~= "ScriptObject" then
					for _, apiTable in pairs(system.Functions or {}) do
						if system.Namespace then
							local fullName = string.format("%s.%s", system.Namespace, apiTable.Name)
							t[fullName] = apiTable
						else
							t[apiTable.Name] = apiTable
						end
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
		local path = "FrameXML/mainline/%s/AddOns/Blizzard_APIDocumentationGenerated"
		local docs = apidoc_nontoc:LoadBlizzardDocs(path:format(version))
		for apiType, apiTable in pairs(self.apiTypes) do
			local map = apiTable.map(docs)
			t[version][apiType] = map
		end
	end
	return t
end

local function main(versions, isWiki)
	local framexml = m:LoadFrameXML(versions)
	local changes = m:CompareVersions(versions, framexml)
	PrintView:PrintView(changes, isWiki)
end

-- main({"10.1.0 (49318)", "10.1.5 (50006)"}, true)
main({"10.1.5 (50006)", "10.1.5 (50438)"}, true)
print("done")
