Wowpedia.basicTypes = {
	bool = true,
	number = true,
	string = true,
	table = true,
}

Wowpedia.complexTypes = {}
Wowpedia.complexRefs = {}

function Wowpedia:GetComplexTypeByName(name)
	if self.complexTypes[name] then
		return self.complexTypes[name]
	else
		error("Unknown Type: "..name)
	end
end

function Wowpedia:GetApiTypeByTable(apiTable)
	if self.basicTypes[apiTable.Type] then
		if apiTable.Type == "table" then
			return self:GetTableSubType(apiTable)
		else
			return apiTable.Type
		end
	elseif self.complexTypes[apiTable.Type] then
		return apiTable.Type
	else
		error("Unknown Type: "..apiTable.Type)
	end
end

function Wowpedia:GetApiTypePretty(apiTable)
	if apiTable.Type == "Enumeration" then
		return "Enum."..apiTable.Name
	elseif apiTable.Type == "Structure" then
		return apiTable.Name
	end
end

function Wowpedia:GetTableSubType(apiTable)
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

function Wowpedia:ShouldTranscludeTable(apiTable)
	if self.complexRefs[apiTable.Name] then
		return self.complexRefs[apiTable.Name] > 1
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
			self.complexRefs[field.Type] = (self.complexRefs[field.Type] or 0) + 1
		end
	end
end

Wowpedia:InitComplexTableTypes()
Wowpedia:InitComplexFieldRefs()
