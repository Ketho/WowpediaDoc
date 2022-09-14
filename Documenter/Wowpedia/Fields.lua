Wowpedia.basicTypes = {
	bool = "boolean",
	number = "number",
	string = "string",
	table = "table",
	["function"] = "function",
}

Wowpedia.complexTypes = {}
Wowpedia.complexRefs = {}
Wowpedia.subTables = {}

-- InitComplexTableTypes
for _, apiInfo in ipairs(APIDocumentation.tables) do
	Wowpedia.complexTypes[apiInfo.Name] = apiInfo
end

-- InitComplexFieldRefs
for _, field in ipairs(APIDocumentation.fields) do
	local parent = field.Function or field.Event or field.Table
	local typeName = field.InnerType or field.Type
	if not Wowpedia.basicTypes[typeName] and parent.Type ~= "Enumeration" then
		Wowpedia.complexRefs[typeName] = (Wowpedia.complexRefs[typeName] or 0) + 1
	end
end

-- InitSubtables
for _, apiTable in ipairs(APIDocumentation.tables) do
	if apiTable.Type == "Structure" then
		for _, field in pairs(apiTable.Fields) do
			Wowpedia.subTables[field.InnerType or field.Type] = true
		end
	end
end

local paramFs = ":;%s:%s"

local function HasMiddleOptionals(paramTbl)
	local optional
	for _, param in ipairs(paramTbl) do
		if param.Nilable then
			optional = true
		else
			if optional then
				return true
			end
		end
	end
end

function Wowpedia:GetSignature(apiTable, apiType)
	local tbl = {}
	local paramTbl = apiTable[apiType]
	if HasMiddleOptionals(paramTbl) then
		for _, param in ipairs(paramTbl) do
			local name = param.Name
			if param:IsOptional() then
				name = format("[%s]", name)
			end
			tinsert(tbl, name)
		end
		return table.concat(tbl, ", ")
	else
		local optionalFound
		for _, param in ipairs(paramTbl) do
			local name = param.Name
			if param:IsOptional() and not optionalFound then
				optionalFound = true
				name = format("[%s", name)
			end
			tinsert(tbl, name)
		end
		local str = table.concat(tbl, ", ")
		return optionalFound and str:gsub(", %[", " [, ").."]" or str
	end
end

function Wowpedia:GetParameters(params, isArgument)
	local tbl = {}
	for _, param in ipairs(params) do
		if param:GetStrideIndex() == 1 then
			tinsert(tbl, format("(Variable %s)", isArgument and "arguments" or "returns"))
		end
		tinsert(tbl, paramFs:format(param.Name, self:GetPrettyType(param, isArgument)))
		local complexTable, isTransclude = self:GetComplexTypeInfo(param)
		if complexTable then
			if isTransclude then
				local transclude = format("{{:%s|nocaption=1}}", self:GetTranscludeBase(complexTable))
				tinsert(tbl, transclude)
			else
				tinsert(tbl, self:GetTableText(complexTable))
			end
		end
	end
	return table.concat(tbl, "\n")
end

function Wowpedia:GetPrettyType(apiTable, isArgument)
	local complexType = self.complexTypes[apiTable.Type]
	local apiText
	if apiTable.Type == "table" then
		if apiTable.Mixin then
			apiText = apiTable.Mixin
		elseif apiTable.InnerType then
			local complexInnertype = self.complexTypes[apiTable.InnerType]
			if self.basicTypes[apiTable.InnerType] then
				apiText = self.basicTypes[apiTable.InnerType].."[]"
			elseif complexInnertype then
				apiText = complexInnertype:GetFullName(false, false).."[]"
			else
				error("Unknown InnerType: "..apiTable.InnerType)
			end
		else
			apiText = "Unknown"
		end
	elseif self.basicTypes[apiTable.Type] then
		apiText = self.basicTypes[apiTable.Type]
	elseif complexType then
		apiText = complexType:GetFullName(false, false)
	else
		error("Unknown Type: "..apiTable.Type)
	end
	-- `Default` implies `Nilable`, even if nilable is false
	if apiTable.Nilable or apiTable.Default ~= nil then
		apiText = apiText.."?"
	end
	local str = string.format("{{apitype|%s}}", apiText)
	if apiTable.Default ~= nil then
		str = format("%s (Default = %s)", str, tostring(apiTable.Default))
	end
	if apiTable.Documentation then
		str = str.." - "..table.concat(apiTable.Documentation, "; ")
	end
	return str
end

function Wowpedia:GetComplexTypeInfo(apiTable)
	local typeName = apiTable.InnerType or apiTable.Type
	if not self.basicTypes[typeName] then
		local complexTable = self.complexTypes[typeName]
		local isTransclude = (self.complexRefs[typeName] or 0) > 1
		return complexTable, isTransclude
	end
end

function Wowpedia:FindMissingTypes()
	local missingTypes = {}
	for _, field in ipairs(APIDocumentation.fields) do
		local parent = field.Function or field.Event or field.Table
		local typeName = field.InnerType or field.Type
		if not self.basicTypes[typeName] and parent.Type ~= "Enumeration" then
			if not self.complexTypes[typeName] then
				missingTypes[typeName] = {field=field, parent=parent}
			end
		end
	end
	return missingTypes
end

function Wowpedia:HasMissingTypes()
	local missingTypes = self:FindMissingTypes()
	if next(missingTypes) then
		print("Found missing complex types, please add them to Documenter/Load_APIDocumentation/MissingDocumentation.lua")
		for complexType, info in pairs(missingTypes) do
			-- print(Enum.ItemSoundType.Use)
			if Enum[complexType] then
				print("Enum:", complexType)
			else
				print("Missing:", complexType, info.parent.Type..": "..info.parent.Name)
			end
		end
		return true
	end
end
