local shortComplex = {
	Enumeration = "Enum",
	Structure = "Struct",
	Constants = "Const",
}

function Wowpedia:GetTableText(apiTable, isTemplate)
	local tbl = {}
	local transclude = self:GetTranscludeBase(apiTable)
	local fullName = apiTable:GetFullName()
	table.insert(tbl, '{| class="sortable darktable zebra" style="margin-left: 2em"')
	if isTemplate then
		table.insert(tbl, string.format("|+ {{#if:{{{nocaption|}}}||[[%s|%s]]}}", transclude, fullName))
	else
		table.insert(tbl, string.format("<!-- |+ [[%s|%s]] -->", transclude, fullName))
	end
	if apiTable.Type == "Enumeration" then
		table.insert(tbl, "! Value !! Key !! Description")
		for _, field in ipairs(apiTable.Fields) do
			table.insert(tbl, string.format('|-\n| align="center" | %s || %s ||', field.EnumValue, field.Name))
		end
	elseif apiTable.Type == "Structure" then
		table.insert(tbl, "! Key !! Type !! Description")
		for _, field in ipairs(apiTable.Fields) do
			local prettyType = self:GetPrettyType(field)
			table.insert(tbl, string.format('|-\n| %s || %s ||', field.Name, prettyType))
		end
	elseif apiTable.Type == "Constants" then
		table.insert(tbl, "! Constant !! Type !! Value !! Description")
		for _, field in ipairs(apiTable.Values) do
			local prettyType = self:GetPrettyType(field)
			table.insert(tbl, string.format('|-\n| %s || %s || align="center" | %s ||', field.Name, prettyType, field.Value))
		end
	end
	table.insert(tbl, "|}")
	local text = table.concat(tbl, "\n")
	return isTemplate and string.format("{{wowapitype}}\n<onlyinclude>%s</onlyinclude>", text) or text
end

function Wowpedia:GetTranscludeBase(complexTable)
	local shortType = shortComplex[complexTable.Type]
	local system, systemName = complexTable.System, "Unknown"
	if system then -- Unit and Expansion systems dont have a namespace
		systemName = system.Namespace and system.Namespace:gsub("C_", "") or system.Name
	end
	return string.format("%s %s.%s", shortType, systemName, complexTable.Name)
end
