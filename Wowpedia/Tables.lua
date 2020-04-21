local tableTemplate = "{{:%s %s.%s}}"
local tableClass = '{| class="sortable darktable zebra" style="margin-left: 2em"'

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

function Wowpedia:GetTableText(apiTable, showCaption)
	if apiTable.Type == "Enumeration" then
		return self:GetDarkTable(apiTable, showCaption, enumHeader, enumRow)
	elseif apiTable.Type == "Structure" then
		return self:GetDarkTable(apiTable, showCaption, structHeader, structRow)
	elseif apiTable.Type == "Constants" then
		return self:GetConstants(apiTable)
	end
end

function Wowpedia:GetDarkTable(apiTable, showCaption, header, row)
	local darkTbl, rows = {}, {}
	table.insert(darkTbl, tableClass)
	if showCaption then
		table.insert(darkTbl, "|+ "..self:GetTableCaption(apiTable))
	end
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
	table.insert(darkTbl, header)
	table.insert(darkTbl, table.concat(rows, "\n"))
	table.insert(darkTbl, "|}")
	return table.concat(darkTbl, "\n")
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

function Wowpedia:GetTableTemplate(complexTable)
	local shortType = shortComplex[complexTable.Type]
	local system = self:GetTableSystem(complexTable)
	return tableTemplate:format(shortType, system, complexTable.Name)
end

function Wowpedia:GetTableCaption(apiTable)
	local isTransclude = select(2, self:GetComplexTypeInfo(apiTable))
	if isTransclude then
		local system = self:GetTableSystem(apiTable)
		if apiTable.Type == "Enumeration" then
			return enumCaption:format(system, apiTable.Name, apiTable.Name)
		elseif apiTable.Type == "Structure" then
			return structCaption:format(system, apiTable.Name, apiTable.Name)
		end
	else
		return apiTable:GetFullName()
	end
end
