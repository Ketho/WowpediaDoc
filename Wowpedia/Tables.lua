local shortComplex = {
	Enumeration = "Enum",
	Structure = "Struct",
	Constants = "Const",
}

function Wowpedia:GetTableText(apiTable, isTemplate, isSubTable)
	local tbl = {}
	local transclude = self:GetTranscludeBase(apiTable)
	local fullName = apiTable:GetFullName()
	tinsert(tbl, '{| class="sortable darktable zebra" style="margin-left: 2em"')
	if isTemplate then
		tinsert(tbl, format("|+ {{#if:{{{nocaption|}}}||[[%s|%s]]}}", transclude, fullName))
	elseif isSubTable then
		tinsert(tbl, format("|+ [[%s|%s]]", transclude, fullName))
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
	local shortType = shortComplex[complexTable.Type]
	return shortType.." "..complexTable.Name, shortType
end
