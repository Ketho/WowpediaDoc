Wowpedia = {}
require "Wowpedia/Functions"
require "Wowpedia/Events"
require "Wowpedia/Tables"
require "Wowpedia/Fields"

local LATEST_PATCH = "9.0.1"

function Wowpedia:GetPageText(apiTable)
	local tbl, systemInfo = {}, {}
	local system = apiTable.System
	local params
	if apiTable.Type == "Function" then
		tinsert(systemInfo, "wowapi")
		params = self:GetFunctionText(apiTable)
	elseif apiTable.Type == "Event" then
		tinsert(systemInfo, "wowapievent")
		params = self:GetEventText(apiTable)
	end
	if system.Namespace then
		tinsert(systemInfo, "namespace="..system.Namespace)
	end
	if system.Name then
		tinsert(systemInfo, "system="..system.Name)
	end
	local template = format("{{%s}}", table.concat(systemInfo, "|"))
	local sections = {
		template,
		self:GetDescription(apiTable),
		params,
		self:GetPatchSection(),
		self:GetElinksSection(systemInfo),
	}
	for _, v in pairs(sections) do
		tinsert(tbl, v)
	end
	return table.concat(tbl, "\n")
end

function Wowpedia:GetDescription(apiTable)
	if apiTable.Documentation then
		return table.concat(apiTable.Documentation, "; ")
	end
	return "Needs summary."
end

function Wowpedia:GetPatchSection()
	return format("==Patch changes==\n* {{Patch %s|note=Added.}}\n", LATEST_PATCH)
end

function Wowpedia:GetElinksSection(systemInfo)
	systemInfo[1] = "Elinks-api"
	local elinks = format("{{%s}}", table.concat(systemInfo, "|"))
	return "==External Links==\n{{subst:el}}\n"..elinks
end
