local basicTypes = {
	bool = true,
	number = true,
	table = true,
}

Wowpedia.complexTypes = {}
local complexRefs = {}

function Wowpedia:GetType(apiTable)
	if basicTypes[apiTable.Type] then
		if apiTable.Type == "table" then
			return self:GetTableType(apiTable)
		else
			return apiTable.Type
		end
	elseif self.complexTypes[apiTable.Type] then
		return apiTable.Type
	else
		error("Unknown Type:", apiTable.Type)
	end
end

function Wowpedia:GetTableType(apiTable)
	if apiTable.Mixin then
		return string.format("[[%s]]", apiTable.Mixin) -- wiki link
	elseif apiTable.InnerType then
		if basicTypes[apiTable.InnerType] or self.complexTypes[apiTable.InnerType] then
			return string.format("%s[]", apiTable.InnerType)
		else
			error("Unknown InnerType:", apiTable.InnerType)
		end
	end
end

function Wowpedia:GetComplexType(name)
	return self.complexTypes[name]
end

function Wowpedia:IsTranscludeTemplate(complexType)
	if complexRefs[complexType] then
		return complexRefs[complexType] > 1
	end
end

function Wowpedia:InitComplexTables()
	local tables = APIDocumentation:GetAPITableByTypeName("table")
	for _, apiInfo in ipairs(tables) do
		self.complexTypes[apiInfo.Name] = apiInfo
	end
end

function Wowpedia:InitComplexRefs()
	for name in pairs(self.complexTypes) do
		complexRefs[name] = 0
	end

	local functions = APIDocumentation:GetAPITableByTypeName("function")
	for _, apiInfo in pairs(functions) do
		if apiInfo.Arguments then
			for _, arg in pairs(apiInfo.Arguments) do
				if self.complexTypes[arg.Type] then
					complexRefs[arg.Type] = complexRefs[arg.Type] + 1
				end
			end
		end
		if apiInfo.Returns then
			for _, ret in pairs(apiInfo.Returns) do
				if self.complexTypes[ret.Type] then
					complexRefs[ret.Type] = complexRefs[ret.Type] + 1
				end
			end
		end
	end

	local events = APIDocumentation:GetAPITableByTypeName("event")
	for _, apiInfo in ipairs(events) do
		if apiInfo.Payload then
			for _, param in pairs(apiInfo.Payload) do
				if self.complexTypes[param.Type] then
					complexRefs[param.Type] = complexRefs[param.Type] + 1
				end
			end
		end
	end

	local tables = APIDocumentation:GetAPITableByTypeName("table")
	for _, apiInfo in ipairs(tables) do
		if apiInfo.Type == "Structure" then
			for _, field in pairs(apiInfo.Fields) do
				local complexType = self.complexTypes[field.Type] or self.complexTypes[field.InnerType]
				if complexType then
					complexRefs[complexType.Name] = complexRefs[complexType.Name] + 1
				end
			end
		end
	end
end

Wowpedia:InitComplexTables()
Wowpedia:InitComplexRefs()
