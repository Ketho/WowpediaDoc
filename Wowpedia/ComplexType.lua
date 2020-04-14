Wowpedia.basicTypes = {
	bool = true,
	number = true,
	string = true,
	table = true,
}

Wowpedia.complexTypes = {}
local complexRefs = {}

function Wowpedia:GetApiType(apiTable)
	if self.basicTypes[apiTable.Type] then
		if apiTable.Type == "table" then
			return self:GetTableType(apiTable)
		else
			return apiTable.Type
		end
	elseif self.complexTypes[apiTable.Type] then
		return apiTable.Type
	else
		error("Unknown Type: "..apiTable.Type)
	end
end

function Wowpedia:GetTableType(apiTable)
	if apiTable.Mixin then
		return string.format("[[%s]]", apiTable.Mixin) -- wiki link
	elseif apiTable.InnerType then
		if self.basicTypes[apiTable.InnerType] or self.complexTypes[apiTable.InnerType] then
			return string.format("%s[]", apiTable.InnerType)
		else
			error("Unknown InnerType: "..apiTable.InnerType)
		end
	end
end

function Wowpedia:ShouldTranscludeTable(complexType)
	if complexRefs[complexType] then
		return complexRefs[complexType] > 1
	end
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
			complexRefs[field.Type] = (complexRefs[field.Type] or 0) + 1
		end
	end
end

Wowpedia:InitComplexTableTypes()
Wowpedia:InitComplexFieldRefs()
