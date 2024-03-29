Wowpedia = {}
require("Documenter/Wowpedia/Functions")
require("Documenter/Wowpedia/Events")
require("Documenter/Wowpedia/Tables")
require("Documenter/Wowpedia/Fields")
require("Documenter/Wowpedia/Missing")

function Wowpedia:GetPageText(apiTable, systemType)
	local tbl = {}
	local params
	if apiTable.Type == "Function" then
		params = self:GetFunctionText(apiTable, systemType)
	elseif apiTable.Type == "Event" then
		params = self:GetEventText(apiTable)
	end
	local apiTemplate = self:GetTemplateInfo(apiTable, systemType)
	local sections = {
		apiTemplate,
		self:GetDescription(apiTable),
		params,
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

function Wowpedia:GetTemplateInfo(apiTable, systemType)
	local tbl = {}
	if systemType == "ScriptObject" then
		tinsert(tbl, "widgetmethod")
	elseif apiTable.Type == "Function" then
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

function Wowpedia:main()
	self:UpdateComplexTableTypes()
	self:InitComplexFieldRefs()
	self:InitSubtables()
	self:InitTypeDocumentation()

	local missingTypes = Wowpedia:FindMissingTypes()
	if next(missingTypes) then
		self:PullMissingTypes(missingTypes)
		self:UpdateComplexTableTypes() -- update complex types again
	end
end
Wowpedia:main()
