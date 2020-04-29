local shortComplex = {
	Enumeration = "Enum",
	Structure = "Struct",
	Constants = "Const",
}

function Wowpedia:GetTableText(apiTable, isTemplate)
	local tbl = {}
	local transclude = self:GetTranscludeBase(apiTable)
	local fullName = apiTable:GetFullName()
	tinsert(tbl, '{| class="sortable darktable zebra" style="margin-left: 2em"')
	if isTemplate then
		tinsert(tbl, format("|+ {{#if:{{{nocaption|}}}||[[%s|%s]]}}", transclude, fullName))
	else
		tinsert(tbl, format("<!-- |+ [[%s|%s]] -->", transclude, fullName))
	end
	if apiTable.Type == "Enumeration" then
		tinsert(tbl, "! Value !! Key !! Description")
		for _, field in ipairs(apiTable.Fields) do
			tinsert(tbl, format('|-\n| align="center" | %s || %s || ', field.EnumValue, field.Name))
		end
	elseif apiTable.Type == "Structure" then
		tinsert(tbl, "! Key !! Type !! Description")
		for _, field in ipairs(apiTable.Fields) do
			local prettyType = self:GetPrettyType(field)
			tinsert(tbl, format('|-\n| %s || %s || ', field.Name, prettyType))
		end
	elseif apiTable.Type == "Constants" then
		tinsert(tbl, "! Constant !! Type !! Value !! Description")
		for _, field in ipairs(apiTable.Values) do
			local prettyType = self:GetPrettyType(field)
			tinsert(tbl, format('|-\n| %s || %s || align="center" | %s || ', field.Name, prettyType, field.Value))
		end
	end
	tinsert(tbl, "|}")
	local text = table.concat(tbl, "\n")
	local apiTemplate = self:GetTemplateInfo(apiTable)
	return isTemplate and format("%s\n<onlyinclude>%s</onlyinclude>", apiTemplate, text) or text
end

function Wowpedia:GetTranscludeBase(complexTable)
	local shortType = shortComplex[complexTable.Type]
	local system, systemName = complexTable.System, "Unknown"
	if system then -- Unit and Expansion systems dont have a namespace
		systemName = system.Namespace and system.Namespace:gsub("C_", "") or system.Name
	end
	return format("%s %s.%s", shortType, systemName, complexTable.Name)
end
