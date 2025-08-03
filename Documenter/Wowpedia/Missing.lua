local log = require("wowdoc.log")

function Wowpedia:FindMissingTypes()
	local missingTypes = {}
	for _, field in ipairs(APIDocumentation.fields) do
		local parent = field.Function or field.Event or field.Table
		local typeName = field.InnerType or field.Type
		if not self.basicTypes[typeName] and parent.Type ~= "Enumeration" then
			if not self.blizzardTypes[typeName] and not self.complexTypes[typeName] then
				missingTypes[typeName] = {field=field, parent=parent}
			end
		end
	end
	return missingTypes
end

function Wowpedia:PullMissingTypes(missingTypes)
	local missingDocs = {Tables = {}}

	local MissingDocumentation = require("WowDocLoader.MissingDocumentation")
	local missingStructures = {} -- lookup table
	for _, v in pairs(MissingDocumentation.Tables) do
		missingStructures[v.Name] = v
	end

	for complexType, info in pairs(missingTypes) do
		if Enum[complexType] then
			log:warn("Fetching missing: Enum."..complexType)
			table.insert(missingDocs.Tables, self:GetMissingEnum(complexType))
		elseif missingStructures[complexType] then
			log:warn("Fetching missing: struct "..complexType)
			-- only get a structure if its missing so it wont overwrite any Blizzard docs if they appear
			table.insert(missingDocs.Tables, missingStructures[complexType])
		else
			log:warn(string.format("Undocumented type: %s (source: %s - %s)",
				complexType, info.parent.Type, info.parent.Name))
		end
	end
	APIDocumentation:AddDocumentationTable(missingDocs)
end

function Wowpedia:GetMissingEnum(name)
	local t = {
		Name = name,
		Type = "Enumeration",
		Fields = {},
	}
	for k, v in pairs(Enum[name]) do
		table.insert(t.Fields, { Name = k, Type = name, EnumValue = v })
	end
	table.sort(t.Fields, function(a, b) return a.EnumValue < b.EnumValue end)
	return t
end
