local constants = require("Documenter/constants")
Wowpedia = {}
require("Documenter/Wowpedia/Functions")
require("Documenter/Wowpedia/Events")
require("Documenter/Wowpedia/Tables")
require("Documenter/Wowpedia/Fields")

function Wowpedia:GetPageText(apiTable)
	local tbl = {}
	local params
	if apiTable.Type == "Function" then
		params = self:GetFunctionText(apiTable)
	elseif apiTable.Type == "Event" then
		params = self:GetEventText(apiTable)
	end
	local apiTemplate = self:GetTemplateInfo(apiTable)
	local sections = {
		apiTemplate,
		self:GetDescription(apiTable),
		params,
		self:GetPatchSection(apiTable),
	}
	for _, v in ipairs(sections) do
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

function Wowpedia:GetPatchSection(apiTable)
	local fullName = self:GetFullName(apiTable)
	local patch = constants.LATEST_MAINLINE:match("%d+%.%d+%.%d+")
	-- if ApiDocsDiff[fullName] then
		-- return format("==Patch changes==\n%s\n", ApiDocsDiff[fullName])
	-- else
		return format("==Patch changes==\n{{Patch %s|note=Added.}}\n", patch)
	-- end
end

function Wowpedia:GetTemplateInfo(apiTable)
	local tbl = {}
	if apiTable.Type == "Function" then
		tinsert(tbl, "wowapi")
		tinsert(tbl, "t=a")
	elseif apiTable.Type == "Event" then
		tinsert(tbl, "wowapievent")
		tinsert(tbl, "t=e")
	elseif apiTable.Type == "Enumeration" or apiTable.Type == "Structure" then
		tinsert(tbl, "wowapitype")
	end
	local system = apiTable.System
	if system then
		if system.Namespace then
			tinsert(tbl, "namespace="..system.Namespace)
		end
		if system.Name then
			tinsert(tbl, "system="..system.Name)
		end
	end
	return format("{{%s}}", table.concat(tbl, "|"))
end

function Wowpedia:GetFullName(apiTable)
	local str = ""
	if apiTable.Type == "Function" then
		if apiTable.System.Namespace then
			str = format("%s.%s", apiTable.System.Namespace, apiTable.Name)
		else
			str = apiTable.Name
		end
	elseif apiTable.Type == "Event" then
		str = apiTable.LiteralName
	end
	return str
end
