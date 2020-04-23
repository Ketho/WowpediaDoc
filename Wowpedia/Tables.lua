local shortComplex = {
	Enumeration = "Enum",
	Structure = "Struct",
}

function Wowpedia:GetTableText(apiTable, isTemplate)
	local tbl = {}
	local transclude = self:GetTranscludeBase(apiTable)
	local fullName = apiTable:GetFullName()
	table.insert(tbl, '{| class="sortable darktable zebra" style="margin-left: 2em"')
	if isTemplate then
		table.insert(tbl, string.format('|+ {{#if:{{{nocaption|}}}||[[%s|%s]]}}', transclude, fullName))
	else
		table.insert(tbl, string.format('<!-- |+ [[%s|%s]] -->', transclude, fullName))
	end
	if apiTable.Type == "Enumeration" then
		table.insert(tbl, "! Value !! Key !! Description")
		table.insert(tbl, self:GetTableRows(apiTable, '|-\n| align="center" | %s || %s || '))
	elseif apiTable.Type == "Structure" then
		table.insert(tbl, "! Key !! Type !! Description")
		table.insert(tbl, self:GetTableRows(apiTable, '|-\n| %s || %s || '))
	elseif apiTable.Type == "Constants" then
		table.insert(tbl, self:GetConstants(apiTable))
	end
	table.insert(tbl, "|}")
	local text = table.concat(tbl, "\n")
	return isTemplate and string.format("{{wowapitype}}\n<onlyinclude>%s</onlyinclude>", text) or text
end

function Wowpedia:GetTableRows(apiTable, row)
	local rows = {}
	if apiTable.Type == "Enumeration" then
		for i, field in ipairs(apiTable.Fields) do
			rows[i] = row:format(field.EnumValue, field.Name)
		end
	elseif apiTable.Type == "Structure" then
		for i, field in ipairs(apiTable.Fields) do
			local prettyType = self:GetPrettyType(field)
			rows[i] = row:format(field.Name, prettyType)
		end
	end
	return table.concat(rows, "\n")
end

-- there is only QuestWatchConsts in QuestConstantsDocumentation.lua
function Wowpedia:GetConstants(apiTable)
	return apiTable.Type
end

function Wowpedia:GetTranscludeBase(complexTable)
	local shortType = shortComplex[complexTable.Type]
	local system, systemName = complexTable.System, "Unknown"
	if system then -- Unit and Expansion systems dont have a namespace
		systemName = system.Namespace and system.Namespace:gsub("C_", "") or system.Name
	end
	return string.format("%s %s.%s", shortType, systemName, complexTable.Name)
end
