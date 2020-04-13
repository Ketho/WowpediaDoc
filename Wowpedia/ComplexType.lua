local baseTypes = {
	bool = true,
	number = true,
	table = true,
}

Wowpedia.complexTypes = {}
local complexRefs = {}

function Wowpedia:GetType(apiTable)
	if baseTypes[apiTable.Type] then
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
		if baseTypes[apiTable.InnerType] or self.complexTypes[apiTable.InnerType] then
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
	for i, apiInfo in ipairs(tables) do
		self.complexTypes[apiInfo.Name] = apiInfo
	end
end

function Wowpedia:InitComplexRefs()
	local functions = APIDocumentation:GetAPITableByTypeName("function")
	for i, apiInfo in ipairs(functions) do
		if apiInfo.Arguments then
			for _, arg in pairs(apiInfo.Arguments) do
				if self.complexTypes[arg.Type] then
					complexRefs[arg.Type] = (complexRefs[arg.Type] or 0) + 1
				end
			end
		end
		if apiInfo.Returns then
			for _, ret in pairs(apiInfo.Returns) do
				if self.complexTypes[ret.Type] then
					complexRefs[ret.Type] = (complexRefs[ret.Type] or 0) + 1
				end
			end
		end
	end

	local events = APIDocumentation:GetAPITableByTypeName("event")
	for i, apiInfo in ipairs(events) do
		if apiInfo.Payload then
			for _, param in pairs(apiInfo.Payload) do
				if self.complexTypes[param.Type] then
					complexRefs[param.Type] = (complexRefs[param.Type] or 0) + 1
				end
			end
		end
	end

	local tables = APIDocumentation:GetAPITableByTypeName("table")
	for i, apiInfo in ipairs(tables) do
		if apiInfo.Fields then -- see QuestWatchConsts which is a "Constants" type
			for _, field in pairs(apiInfo.Fields) do
				local complexType = self.complexTypes[field.Type] or self.complexTypes[field.InnerType]
				if complexType then
					complexRefs[complexType] = (complexRefs[complexType] or 0) + 1
				end
			end
		end
	end
end

Wowpedia:InitComplexTables()
Wowpedia:InitComplexRefs()
