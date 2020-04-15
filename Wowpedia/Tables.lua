local tableTemplate = "{{%s %s.%s}}"
local enumCaption = "[[Enum %s.%s|Enum.%s]]"
local structCaption = "[[Struct %s.%s|%s]]"
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

-- there probably is a more straightforward way to do all this
function Wowpedia:GetTableTemplateOrText(apiTable, forceText)
	if self:ShouldTranscludeTable(apiTable) and not forceText then
		return self:GetTableTemplate(apiTable)
	else
		return self:GetTableText(apiTable)
	end
end

function Wowpedia:GetTableText(apiTable)
	return self["Get"..apiTable.Type](self, apiTable)
end

function Wowpedia:GetEnumeration(apiTable)
	local t = {}
	for i, field in ipairs(apiTable.Fields) do
		t[i] = rowFs:format(field.EnumValue, field.Name)
	end
	local caption = self:GetTableCaption(apiTable)
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
	local caption = self:GetTableCaption(apiTable)
	local rows = table.concat(t, "\n")
	return darkTableFs:format(caption, structHeader, rows)
end

-- there is only QuestWatchConsts in QuestConstantsDocumentation.lua
function Wowpedia:GetConstants()
end

function Wowpedia:GetTableSystem(apiTable)
	local system = apiTable.System
	if system then -- Unit and Expansion systems dont have a namespace
		return system.Namespace and system.Namespace:gsub("C_", "") or system.Name
	else
		return "Unknown"
	end
end

function Wowpedia:GetTableTemplate(apiTable)
	local shortType = shortComplex[apiTable.Type]
	local system = self:GetTableSystem(apiTable)
	return tableTemplate:format(shortType, system, apiTable.Name)
end

function Wowpedia:GetTableCaption(apiTable)
	if self:ShouldTranscludeTable(apiTable) then
		return self:GetTableCaptionLink(apiTable)
	else
		return self:GetTableCaptionRaw(apiTable)
	end
end

function Wowpedia:GetTableCaptionLink(apiTable)
	local system = self:GetTableSystem(apiTable)
	if apiTable.Type == "Enumeration" then
		return enumCaption:format(system, apiTable.Name, apiTable.Name)
	elseif apiTable.Type == "Structure" then
		return structCaption:format(system, apiTable.Name, apiTable.Name)
	end
end

function Wowpedia:GetTableCaptionRaw(apiTable)
	if apiTable.Type == "Enumeration" then
		return "Enum."..apiTable.Name
	elseif apiTable.Type == "Structure" then
		return apiTable.Name
	end
end
