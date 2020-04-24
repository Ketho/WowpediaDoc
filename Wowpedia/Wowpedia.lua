Wowpedia = {}
require "Wowpedia/Functions"
require "Wowpedia/Events"
require "Wowpedia/Tables"
require "Wowpedia/Fields"

local LATEST_PATCH = "9.0.1"

function Wowpedia:GetPageText(apiTable)
	local tbl = {}
	local template, params
	if apiTable.Type == "Function" then
		template = "{{wowapi}}"
		params = self:GetFunctionText(apiTable)
	elseif apiTable.Type == "Event" then
		local system = apiTable.System
		template = format("{{wowapievent|%s}}", system.Namespace or system.Name)
		params = self:GetEventText(apiTable)
	end
	local sections = {
		template,
		self:GetDescription(apiTable),
		params,
		self:GetPatchSection(),
		self:GetElinksSection(),
	}
	for _, v in pairs(sections) do
		tinsert(tbl, v)
	end
	return table.concat(tbl, "\n")
end

function Wowpedia:GetDescription(apiTable)
	if apiTable.Documentation then
		return apiTable.Documentation[1]
	end
	return "Needs summary."
end

function Wowpedia:GetPatchSection()
	return format("==Patch changes==\n* {{Patch %s|note=Added.}}\n", LATEST_PATCH)
end

function Wowpedia:GetElinksSection()
	return "==External Links==\n{{subst:el}}\n{{Elinks-api}}"
end
