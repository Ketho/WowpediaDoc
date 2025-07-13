local util = require("util")

local shortComplex = {
	Enumeration = "Enum",
	Structure = "Struct",
	Constants = "Const",
	CallbackType = "Callback",
}

local alignFirstCol = {
	Enumeration = true,
	Constants = true,
}

function Wowpedia:GetTableText(apiTable, isTemplate, isSubTable)
	local tbl = {}
	local transclude = self:GetTranscludeBase(apiTable)
	local fullName = apiTable:GetFullName()
	local tableClass = '{| class="sortable darktable zebra'
	if alignFirstCol[apiTable.Type] then
		tableClass = tableClass.." col1-center"
	end
	tableClass = tableClass..'" style="margin-left: 3.9em"'
	tinsert(tbl, tableClass)
	if isTemplate then
		-- local link
		-- if transclude == fullName then -- Enum; save some space
		-- 	link = transclude
		-- else -- Struct
		-- 	link = format("%s|%s", transclude, fullName)
		-- end
		tinsert(tbl, format("|+ {{#if:{{{nocaption|}}}||%s}}", fullName))
	elseif isSubTable then
		tinsert(tbl, format("|+ %s", fullName))
	end
	if apiTable.Type == "Enumeration" then
		local isBitEnum = util:IsBitEnum(apiTable)
		tinsert(tbl, "! Value !! Field !! Description")
		for _, field in ipairs(apiTable.Fields) do
			tinsert(tbl, format('|-\n| %s || {{apiname|%s}} || ', isBitEnum and string.format("0x%X", field.EnumValue) or field.EnumValue, field.Name))
		end
	elseif apiTable.Type == "Structure" then
		tinsert(tbl, "! Field !! Type !! Description")
		for _, field in ipairs(apiTable.Fields) do
			local prettyType = self:GetPrettyType(field)
			tinsert(tbl, format('|-\n| {{apiname|%s}} || %s || ', field.Name, prettyType))
		end
	elseif apiTable.Type == "Constants" then
		tinsert(tbl, "! Constant !! Type !! Value !! Description")
		for _, field in ipairs(apiTable.Values) do
			local prettyType = self:GetPrettyType(field)
			tinsert(tbl, format('|-\n| {{apiname|%s}} || %s || %s || ', field.Name, prettyType, field.Value))
		end
	end
	tinsert(tbl, "|}")
	local text = table.concat(tbl, "\n")
	local includedTables = self:GetIncludedTables(apiTable)
	if #includedTables > 0 then
		text = text.."\n\n"..table.concat(includedTables, "\n\n")
	end
	local apiTemplate = self:GetTemplateInfo(apiTable)
	return isTemplate and format("%s\n<onlyinclude>%s</onlyinclude>", apiTemplate, text) or text
end

function Wowpedia:GetIncludedTables(apiTable)
	local tbl, tblHash = {}, {}
	if apiTable.Type == "Structure" then
		for _, field in ipairs(apiTable.Fields) do
			local complexTable, isTransclude = self:GetComplexTypeInfo(field)
			if complexTable and not tblHash[complexTable] then
				tblHash[complexTable] = true
				if isTransclude then
					local transclude = format("{{:%s}}", self:GetTranscludeBase(complexTable))
					tinsert(tbl, transclude)
				else
					tinsert(tbl, self:GetTableText(complexTable, false, true))
				end
			end
		end
	end
	return tbl
end

function Wowpedia:GetTranscludeBase(complexTable)
	local shortType = shortComplex[complexTable.Type] or complexTable.Type
	local divider = shortType == "Enum" and "." or " "
	return shortType..divider..complexTable.Name, shortType
end
