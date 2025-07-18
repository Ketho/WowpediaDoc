-- compares framexml versions
local log = require("util.log")
local products = require("util.products")
local enum = require("util.enum")

local PRODUCT = "wow"
local _, branch = products:GetBranch(PRODUCT)
enum:LoadLuaEnums(branch)
local apidoc_nontoc = require("util.apidoc_nontoc")

local BUILD1 = "11.2.0 (61871)"
local BUILD2 = "11.2.0 (61981)"

ChangeDiff = {}
require("Projects.ChangeDiff.Compare")
local m = ChangeDiff
local PrintView = require("Projects.ChangeDiff.PrintView")

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
	Enumeration = {
		map = function(tbl)
			local t = {}
			for _, system in pairs(tbl) do
				for _, apiTable in pairs(system.Tables or {}) do
					if apiTable.Type == "Enumeration" then
						t[apiTable.Name] = apiTable
					end
				end
			end
			return t
		end,
		params = {"Fields"},
	},
	Structure = {
		map = function(tbl)
			local t = {}
			for _, system in pairs(tbl) do
				for _, apiTable in pairs(system.Tables or {}) do
					if apiTable.Type == "Structure" then
						t[apiTable.Name] = apiTable
					end
				end
			end
			return t
		end,
		params = {"Fields"},
	},
}
m.apiType_order = {"Function", "Event", "Enumeration", "Structure"}

function m:LoadFrameXML(versions)
	local t = {}
	for _, version in pairs(versions) do
		t[version] = {}
		local path = "FrameXML/mainline/%s/Interface/AddOns/Blizzard_APIDocumentationGenerated"
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

main({BUILD1, BUILD2}, true)
log:success("Done")
