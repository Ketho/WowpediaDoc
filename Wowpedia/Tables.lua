local tableTemplate = "{{%s_%s.%s}}"
local tableCaption = "[[%s_%s.%s|Enum.%s]]"
local enumHeader = "! Value !! Key !! Description"
local structHeader = "! Key !! Type !! Description"
local rowFs = '|-\n| align="center" | %s || %s || '

local shortComplex = {
	Enumeration = "Enum",
	Structure = "Struct",
}

local darkTableFs = [[{| class="sortable darktable zebra" style="margin-left: 2em"
|+ %s
%s
%s
|}
]]

function Wowpedia:GetTableByName(complexType)
	local apiTable = self.complexTypes[complexType]
	if apiTable then
		return apiTable
	else
		error("Unknown Table: "..complexType)
	end
end

function Wowpedia:GetTableText(apiTable)
	if apiTable.Type == "Enumeration" then
		return self:GetEnumeration(apiTable)
	elseif apiTable.Type == "Structure" then
		return self:GetStructure(apiTable)
	elseif apiTable.Type == "Constants" then
		return self:GetConstants(apiTable)
	end
end

function Wowpedia:GetEnumeration(apiTable)
	local t = {}
	for i, field in ipairs(apiTable.Fields) do
		t[i] = rowFs:format(field.EnumValue, field.Name)
	end
	local caption = self:GetTableLink(apiTable, "caption")
	local rows = table.concat(t, "\n")
	return darkTableFs:format(caption, enumHeader, rows)
end

function Wowpedia:GetStructure(apiTable)
	local t = {}
	for i, field in ipairs(apiTable.Fields) do
		local fieldType = field.Type
		if field.Nilable then
			fieldType = fieldType.." (nilable)"
		end
		t[i] = rowFs:format(field.Name, fieldType)
	end
	local caption = self:GetTableLink(apiTable, "caption")
	local rows = table.concat(t, "\n")
	return darkTableFs:format(caption, structHeader, rows)
end

function Wowpedia:GetConstants(apiTable)
end

function Wowpedia:GetTableLink(apiTable, linkType)
	local complexType = shortComplex[apiTable.Type]
	local system = "Unknown"
	if apiTable.System then
		system = apiTable.System.Namespace:gsub("C_", "")
	end
	if linkType == "template" then
		return tableTemplate:format(complexType, system, apiTable.Name)
	elseif linkType == "caption" then
		if self:ShouldTranscludeTable(apiTable) then
			return tableCaption:format(complexType, system, apiTable.Name, apiTable.Name)
		else -- todo: refactor
			if apiTable.Type == "Enumeration" then
				return "Enum."..apiTable.Name
			else
				return apiTable.Name
			end
		end
	end
end

