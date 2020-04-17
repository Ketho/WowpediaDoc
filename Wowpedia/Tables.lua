local tableTemplate = "{{:%s %s.%s}}"

local enumCaption = "[[Enum %s.%s|Enum.%s]]"
local enumHeader = "! Value !! Key !! Description"
local enumRow = '|-\n| align="center" | %s || %s || '

local structCaption = "[[Struct %s.%s|%s]]"
local structHeader = "! Key !! Type !! Description"
local structRow = '|-\n| %s || %s || '

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

-- there probably is a more straightforward way to do all this
function Wowpedia:GetTableTemplateOrText(apiTable, forceText)
	if self:ShouldTranscludeTable(apiTable) and not forceText then
		return self:GetTableTemplate(apiTable)
	else
		return self:GetTableText(apiTable)
	end
end

function Wowpedia:GetTableText(apiTable)
	if apiTable.Type == "Enumeration" then
		return self:GetDarkTable(apiTable, enumHeader, enumRow)
	elseif apiTable.Type == "Structure" then
		return self:GetDarkTable(apiTable, structHeader, structRow)
	elseif apiTable.Type == "Constants" then
		return self:GetConstants(apiTable)
	end
end

function Wowpedia:GetDarkTable(apiTable, header, row)
	local t = {}
	if apiTable.Type == "Enumeration" then
		for i, field in ipairs(apiTable.Fields) do
			t[i] = row:format(field.EnumValue, field.Name)
		end
	elseif apiTable.Type == "Structure" then
		for i, field in ipairs(apiTable.Fields) do
			local prettyType = self:GetPrettyType(field)
			t[i] = row:format(field.Name, prettyType)
		end
	end
	local caption = self:GetTableCaptionLinkOrName(apiTable)
	local rows = table.concat(t, "\n")
	return darkTableFs:format(caption, header, rows)
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

function Wowpedia:GetTableTemplate(apiTable)
	local shortType = shortComplex[apiTable.Type]
	local system = self:GetTableSystem(apiTable)
	return tableTemplate:format(shortType, system, apiTable.Name)
end

function Wowpedia:GetTableCaptionLinkOrName(apiTable)
	if self:ShouldTranscludeTable(apiTable) then
		return self:GetTableCaptionLink(apiTable)
	else
		return apiTable:GetFullName()
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
