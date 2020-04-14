local tableTemplate = "{{%s_%s.%s}}"
local enumHeader = "! Value !! Key !! Description"
local enumRow = '|-\n| align="center" | %d || %s || '

local shortComplex = {
	Enumeration = "Enum",
	Structure = "Struct",
}

function Wowpedia:GetDarkTable(header, caption)
	local str = '{| class="sortable darktable zebra" style="margin-left: 2em"'
	if caption then
		str = str.."\n|+ "..caption.."\n"
	end
	return str..header.."\n%s\n|}"
end

function Wowpedia:GetTable(complexType)
	local apiTable = self.complexTypes[complexType]
	if self:ShouldTranscludeTable(complexType) then
		return self:GetTableTemplate(apiTable)
	else
		return self:GetTableText(apiTable)
	end
end

function Wowpedia:GetTableTemplate(apiTable)
	local complexType = shortComplex[apiTable.Type]
	local system = "Unknown"
	if apiTable.System.Namespace then
		system = apiTable.System.Namespace:gsub("C_", "")
	end
	return tableTemplate:format(complexType, system, apiTable.Name)
end

function Wowpedia:GetTableText(apiTable)
	if apiTable.Type == "Enumeration" then
		return self:GetEnumerationText(apiTable)
	elseif apiTable.Type == "Structure" then
		return self:GetStructureText(apiTable)
	end
end

function Wowpedia:GetEnumerationText(apiTable)
	local rows = {}
	for i, field in ipairs(apiTable.Fields) do
		rows[i] = enumRow:format(field.EnumValue, field.Name)
	end
	local rowsText = table.concat(rows, "\n")
	local darkTable = self:GetDarkTable(enumHeader, apiTable.Name)
	return darkTable:format(rowsText)
end

function Wowpedia:GetStructureText()
end

function Wowpedia:GetTableCaption(apiTable, isTransclude)
end
