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
local colorComplex = "4ec9b0" -- from vscode dark+ theme

function Wowpedia:GetParameters(params, isArgument)
	local t = {}
	for i, param in ipairs(params) do
		t[i] = paramFs:format(param.Name, self:GetPrettyType(param, isArgument))
	end
	for _, param in ipairs(params) do
		local complexTable, isTransclude = self:GetComplexTypeInfo(param)
		if complexTable then
			if isTransclude then
				table.insert(t, self:GetTableTemplate(complexTable))
			else
				table.insert(t, self:GetTableText(complexTable, #params>1))
			end
		end
	end
	return table.concat(t, "\n")
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
				str = colorFs:format(colorBasic, complexInnertype:GetFullName()).."[]"
			else
				error("Unknown InnerType: "..apiTable.InnerType)
			end
		end
	elseif self.basicTypes[apiTable.Type] then
		str = colorFs:format(colorBasic, self.basicTypes[apiTable.Type])
	elseif complexType then
		str = colorFs:format(colorComplex, complexType:GetFullName())
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

function Wowpedia:GetParamTypeField(apiTable)
	if apiTable.Function then
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
		if not self.basicTypes[field.Type] and parent.Type ~= "Enumeration" then
			self.complexRefs[field.Type] = (self.complexRefs[field.Type] or 0) + 1
		end
	end
end

Wowpedia:InitComplexTableTypes()
Wowpedia:InitComplexFieldRefs()
