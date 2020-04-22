local enumRow = '|-\n| align="center" | %s || %s || '
local structRow = '|-\n| %s || %s || '

local shortComplex = {
	Enumeration = "Enum",
	Structure = "Struct",
}

function Wowpedia:GetTableInlineText(apiTable)
	local tbl = {}
	table.insert(tbl, '{| class="sortable darktable zebra" style="margin-left: 2em"')
	if apiTable.Type == "Enumeration" then
		table.insert(tbl, "! Value !! Key !! Description")
		table.insert(tbl, self:GetDarkTableRows(apiTable, enumRow))
	elseif apiTable.Type == "Structure" then
		table.insert(tbl, "! Key !! Type !! Description")
		table.insert(tbl, self:GetDarkTableRows(apiTable, structRow))
	elseif apiTable.Type == "Constants" then
		table.insert(tbl, self:GetConstants(apiTable))
	end
	table.insert(tbl, "|}")
	return table.concat(tbl, "\n")
end

-- support enum/struct templates by Ddcorkum
function Wowpedia:GetTableStandaloneText(apiTable)
	local tbl = {}
	local _, baseTransclude = self:GetTableTranscludeText(apiTable)
	if apiTable.Type == "Enumeration" then
		table.insert(tbl, "<onlyinclude>{{Enum/Start}}")
		table.insert(tbl, self:GetDarkTableRows(apiTable, enumRow))
		table.insert(tbl, string.format("{{Enum/End|%s}}</onlyinclude>", baseTransclude))
	elseif apiTable.Type == "Structure" then
		table.insert(tbl, "<onlyinclude>{{Struct/Start}}")
		table.insert(tbl, self:GetDarkTableRows(apiTable, structRow))
		table.insert(tbl, string.format("{{Struct/End|%s}}</onlyinclude>", baseTransclude))
	elseif apiTable.Type == "Constants" then
		table.insert(tbl, self:GetConstants(apiTable))
	end
	return table.concat(tbl, "\n")
end

function Wowpedia:GetDarkTableRows(apiTable, row)
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

function Wowpedia:GetTableSystem(apiTable)
	local system = apiTable.System
	if system then -- Unit and Expansion systems dont have a namespace
		return system.Namespace and system.Namespace:gsub("C_", "") or system.Name
	else
		return "Unknown"
	end
end

function Wowpedia:GetTableTranscludeText(complexTable)
	local shortType = shortComplex[complexTable.Type]
	local system = self:GetTableSystem(complexTable)
	local base = string.format("%s %s.%s", shortType, system, complexTable.Name)
	local transclude = string.format("{{:%s}}", base)
	return transclude, base
end
