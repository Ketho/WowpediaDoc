Wowpedia.basicTypes = {
	bool = "boolean",
	number = "number",
	string = "string",
	table = "table",
}

Wowpedia.complexTypes = {}
Wowpedia.complexRefs = {}

local paramFs = ";%s : %s"
local colorFs = '<font color="#%s">%s</font>'
local colorBasic = "ecbc2a" -- from ddcorkum api template
local colorStruct = "4ec9b0" -- from vscode dark+ theme

local complexTypeColors = {
	Enumeration = colorBasic,
	Structure = colorStruct,
}

function Wowpedia:GetSignature(apiTable, paramTbl)
	local str, optionalFound
	for i, param in ipairs(apiTable[paramTbl]) do
		local name = param.Name
		-- usually everything after the first optional argument is also optional
		if param:IsOptional() and not optionalFound then
			optionalFound = true
			name = "["..name
		end
		str = (i==1) and name or str..", "..name
	end
	return optionalFound and str:gsub(", %[", " [, ").."]" or str
end

function Wowpedia:GetParameters(params, isArgument)
	local tbl = {}
	for _, param in ipairs(params) do
		table.insert(tbl, paramFs:format(param.Name, self:GetPrettyType(param, isArgument)))
		local complexTable, isTransclude = self:GetComplexTypeInfo(param)
		if complexTable then
			if isTransclude then
				local transclude = string.format("{{:%s|nocaption=1}}", self:GetTranscludeBase(complexTable))
				table.insert(tbl, transclude)
			else
				table.insert(tbl, self:GetTableText(complexTable))
			end
		end
	end
	return table.concat(tbl, "\n")
end

function Wowpedia:GetPrettyType(apiTable, isArgument)
	local complexType, str = self.complexTypes[apiTable.Type]
	if apiTable.Type == "table" then
		if apiTable.Mixin then
			str = string.format("[[%s]]", apiTable.Mixin) -- wiki link
		elseif apiTable.InnerType then
			local complexInnertype = self.complexTypes[apiTable.InnerType]
			if self.basicTypes[apiTable.InnerType] then
				str = colorFs:format(colorBasic, self.basicTypes[apiTable.InnerType]).."[]"
			elseif complexInnertype then
				local color = complexTypeColors[complexInnertype.Type]
				str = colorFs:format(color, complexInnertype:GetFullName()).."[]"
			else
				error("Unknown InnerType: "..apiTable.InnerType)
			end
		end
	elseif self.basicTypes[apiTable.Type] then
		str = colorFs:format(colorBasic, self.basicTypes[apiTable.Type])
	elseif complexType then
		local color = complexTypeColors[complexType.Type]
		str = colorFs:format(color, complexType:GetFullName())
	else
		error("Unknown Type: "..apiTable.Type)
	end
	local nilableType = isArgument and "optional" or "nilable"
	if apiTable.Default ~= nil then
		str = string.format("%s (%s, default = %s)", str, nilableType, tostring(apiTable.Default))
	elseif apiTable.Nilable then
		str = string.format("%s (%s)", str, nilableType)
	end
	return str
end

function Wowpedia:GetDocumentation()
	--if apiTable.Documentation then
	--end
end

function Wowpedia:GetStrideIndex()
	--if apiTable.StrideIndex then
	--end
end

function Wowpedia:GetParamTypeField(apiTable)
	if apiTable.Function or apiTable.Event then
		return apiTable.InnerType or apiTable.Type
	elseif apiTable.Table then
		return apiTable.Name
	end
end

function Wowpedia:GetComplexTypeInfo(apiTable)
	local typeName = self:GetParamTypeField(apiTable)
	local complexTable = self.complexTypes[typeName]
	local isTransclude = (self.complexRefs[typeName] or 0) > 1
	return complexTable, isTransclude
end

function Wowpedia:InitComplexTableTypes()
	local tables = APIDocumentation:GetAPITableByTypeName("table")
	for _, apiInfo in ipairs(tables) do
		self.complexTypes[apiInfo.Name] = apiInfo
	end
end

function Wowpedia:InitComplexFieldRefs()
	for _, field in pairs(APIDocumentation.fields) do
		local parent = field.Function or field.Event or field.Table
		local typeName = self:GetParamTypeField(field)
		if not self.basicTypes[typeName] and parent.Type ~= "Enumeration" then
			self.complexRefs[typeName] = (self.complexRefs[typeName] or 0) + 1
		end
	end
end

Wowpedia:InitComplexTableTypes()
Wowpedia:InitComplexFieldRefs()

