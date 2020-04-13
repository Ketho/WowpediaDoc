local baseTypes = {
	bool = true,
	number = true,
	table = true,
}

local complexTypes = {}
local complexRefs = {}

function Wowpedia:GetType(param)
	if baseTypes[param.Type] then
		return param.Type == "table" and self:GetTableType(param) or param.Type
	else
		return self:GetComplexType(param)
	end
end

function Wowpedia:GetTableType(param)
	if param.Mixin then
		return string.format("[[%s]]", param.Mixin)
	-- elseif obj.InnerType then
	-- 	return self:GetTableType(obj.InnerType)
	end
end

function Wowpedia:GetComplexType(param)
	return complexTypes[param.Type] and param.Type or "unknown"
end

function Wowpedia:IsTranscludeTemplate(complexType)
	if complexRefs[complexType] then
		return complexRefs[complexType] > 1
	end
end

function Wowpedia:InitComplexTables()
	local tables = APIDocumentation:GetAPITableByTypeName("table")
	for i, apiInfo in ipairs(tables) do
		complexTypes[apiInfo.Name] = apiInfo.Type
	end
end

function Wowpedia:InitComplexRefs()
	local functions = APIDocumentation:GetAPITableByTypeName("function")
	for i, apiInfo in ipairs(functions) do
		if apiInfo.Arguments then
			for _, arg in pairs(apiInfo.Arguments) do
				if complexTypes[arg.Type] then
					complexRefs[arg.Type] = (complexRefs[arg.Type] or 0) + 1
				end
			end
		end
		if apiInfo.Returns then
			for _, ret in pairs(apiInfo.Returns) do
				if complexTypes[ret.Type] then
					complexRefs[ret.Type] = (complexRefs[ret.Type] or 0) + 1
				end
			end
		end
	end

	local events = APIDocumentation:GetAPITableByTypeName("event")
	for i, apiInfo in ipairs(events) do
		if apiInfo.Payload then
			for _, param in pairs(apiInfo.Payload) do
				if complexTypes[param.Type] then
					complexRefs[param.Type] = (complexRefs[param.Type] or 0) + 1
				end
			end
		end
	end

	local tables = APIDocumentation:GetAPITableByTypeName("table")
	for i, apiInfo in ipairs(tables) do
		if apiInfo.Fields then -- see QuestWatchConsts which is a "Constants" type
			for _, field in pairs(apiInfo.Fields) do
				local complexType = complexTypes[field.Type] or complexTypes[field.InnerType]
				if complexType then
					complexRefs[complexType] = (complexRefs[complexType] or 0) + 1
				end
			end
		end
	end
end

Wowpedia:InitComplexTables()
Wowpedia:InitComplexRefs()
