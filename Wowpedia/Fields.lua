Wowpedia.basicTypes = {
	bool = true,
	number = true,
	string = true,
	table = true,
}

Wowpedia.complexTypes = {}
Wowpedia.complexRefs = {}
local paramFs = ";%s : %s"
local colorFs = '<font color="#%s">%s</font>'

function Wowpedia:GetParameters(params, isArgument)
	local t = {}
	for i, param in ipairs(params) do
		t[i] = paramFs:format(param.Name, self:GetPrettyType(param, isArgument))
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
				str = colorFs:format(apiTable:GetLinkHexColor(), apiTable.InnerType).."[]"
			elseif complexInnertype then
				str = colorFs:format(complexInnertype:GetLinkHexColor(), complexInnertype:GetFullName()).."[]"
			else
				error("Unknown InnerType: "..apiTable.InnerType)
			end
		end
	elseif self.basicTypes[apiTable.Type] then
		str = colorFs:format(apiTable:GetLinkHexColor(), apiTable.Type)
	elseif complexType then
		str = colorFs:format(complexType:GetLinkHexColor(), complexType:GetFullName())
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
end

function Wowpedia:GetComplexTypeByName(name)
	if self.complexTypes[name] then
		return self.complexTypes[name]
	else
		error("Unknown Type: "..name)
	end
end

function Wowpedia:ShouldTranscludeTable(apiTable)
	return (self.complexRefs[apiTable.Name] or 0) > 1
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
