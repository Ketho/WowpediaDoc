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

function Wowpedia:GetParameters(params, colorName)
	local argTbl = {}
	for i, param in ipairs(params) do
		local prettyType = self:GetPrettyType(param)
		argTbl[i] = paramFs:format(param.Name, prettyType)
	end
	return table.concat(argTbl, "\n")
end

function Wowpedia:GetPrettyType(apiTable)
	local str, complexType = "", self.complexTypes[apiTable.Type]
	if apiTable.Type == "table" then
		if apiTable.Mixin then
			str = string.format("[[%s]]", apiTable.Mixin) -- wiki link
		elseif apiTable.InnerType then
			if self.basicTypes[apiTable.InnerType] or self.complexTypes[apiTable.InnerType] then
				str = colorFs:format("ffdd55", apiTable.InnerType.."[]")
			else
				error("Unknown InnerType: "..apiTable.InnerType)
			end
		end
	elseif self.basicTypes[apiTable.Type] then
		str = colorFs:format("ffdd55", apiTable.Type)
	elseif complexType then
		str = colorFs:format(complexType:GetLinkHexColor(), complexType:GetFullName())
	else
		error("Unknown Type: "..apiTable.Type)
	end
	if apiTable.Default ~= nil then
		str = str.." (optional, default = "..tostring(arg.Default)..")"
	elseif apiTable.Nilable then
		str = str.." (optional)"
	end
	return str
end

function Wowpedia:GetComplexTypeByName(name)
	if self.complexTypes[name] then
		return self.complexTypes[name]
	else
		error("Unknown Type: "..name)
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
