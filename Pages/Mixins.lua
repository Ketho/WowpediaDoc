-- https://wowpedia.fandom.com/wiki/Category:Mixins
local Util = require("Util/Util")
local OUTPUT = "out/page/%s.txt"
local BRANCH = "mainline"
-- require("Documenter.Load_APIDocumentation.Loader"):main(BRANCH)
require("WowDocLoader.WowDocLoader"):main("WowDocLoader")

local mixinTypes = {
	"ColorMixin",
	"ItemLocationMixin",
	"ItemMixin",
	"PlayerLocationMixin",
	"SpellMixin",
	"TransmogLocationMixin",
	"Vector2DMixin",
	"Vector3DMixin",
}

local function GetWidgetName(s)
	s = s:gsub("^Simple", "")
	s = s:gsub("API:", ":")
	return s
end

local function GetMixinReferences()
	local t = {
		functions = {
			Arguments = {},
			Returns = {},
		},
		events = {},
		tables = {},
	}
	for _, func in pairs(APIDocumentation.functions) do
		for _, field in pairs(func.Arguments or {}) do
			if field.Mixin then
				local fullName = Util:GetFullName(func)
				t.functions.Arguments[fullName] = field.Mixin
			end
		end
		for _, field in pairs(func.Returns or {}) do
			if field.Mixin then
				local fullName = Util:GetFullName(func)
				t.functions.Returns[fullName] = field.Mixin
			end
		end
	end
	for _, event in pairs(APIDocumentation.events) do
		for _, field in pairs(event.Payload or {}) do
			if field.Mixin then
				t.events[event.LiteralName] = field.Mixin
			end
		end
	end
	for _, Table in pairs(APIDocumentation.tables) do
		for _, field in pairs(Table.Fields or {}) do
			if field.Mixin then
				t.tables[Table.Name] = field.Mixin
			end
		end
	end
	return t
end

local function GetMixinRestructured(data, mixin)
	local t = {
		func_args = {},
		func_rets = {},
		events = {},
		tables = {},
	}
	for func, name in pairs(data.functions.Arguments) do
		if name == mixin then
			t.func_args[func] = true
		end
	end
	for func, name in pairs(data.functions.Returns) do
		if name == mixin then
			t.func_rets[func] = true
		end
	end
	for event, name in pairs(data.events) do
		if name == mixin then
			t.events[event] = true
		end
	end
	for Table, name in pairs(data.tables) do
		if name == mixin then
			t.tables[Table] = true
		end
	end
	return t
end

local function GetTableOwners(mixinTables)
	local tableTypes = {}
	for _, Table in pairs(APIDocumentation.tables) do
		tableTypes[Table.Name] = true
	end
	local map = {}
	local function GetTypeInfo(field, owner, ownerName)
		local _type = field.InnerType or field.Type
		if tableTypes[_type] then
			map[_type] = map[_type] or {}
			table.insert(map[_type], {owner = owner, name = ownerName})
		end
	end
	for _, func in pairs(APIDocumentation.functions) do
		for _, field in pairs(func.Arguments or {}) do
			GetTypeInfo(field, func, Util:GetFullName(func))
		end
		for _, field in pairs(func.Returns or {}) do
			GetTypeInfo(field, func, Util:GetFullName(func))
		end
	end
	for _, event in pairs(APIDocumentation.events) do
		for _, field in pairs(event.Payload or {}) do
			GetTypeInfo(field, event, event.LiteralName)
		end
	end
	return map
end

local order = {
	{"func_args", "Function arguments"},
	{"func_rets", "Function returns"},
	{"events", "Events"},
	{"tables", "Structures"},
}

local function FormatLink(cat, name)
	local s = name
	if cat == "func_args" or cat == "func_rets" then
		if name:find(":") then -- hacky but it works
			s = string.format("{{api|t=w|%s}}", GetWidgetName(s))
		else
			s = string.format("{{api|%s}}", name)
		end
	elseif cat == "events" then
		s = string.format("{{api|t=e|%s}}", name)
	end
	return s
end

local function WriteFile(mixin, info, owners)
	local path = OUTPUT:format(mixin)
	local fs = ": %s\n"
	print("writing to "..path)
	local file = io.open(path, "w")
	file:write('{| class="darktable"\n')
	for idx, tbl in pairs(order) do
		local cat_key, cat_label = tbl[1], tbl[2]
		if next(info[cat_key]) then
			if idx > 1 then
				file:write("|-\n")
			end
			file:write(string.format("| %s\n", cat_label))
			-- bleh what a mess
			if cat_key == "tables" then
				for _, name in pairs(Util:SortTable(info[cat_key])) do
					local link = FormatLink(cat_key, name)
					if owners[name] then
						file:write(fs:format(link))
						for k, v in pairs(owners[name]) do
							if v.owner.Type == "Function" then
								if v.name:find(":") then -- widget
									file:write(string.format(":: {{api|t=w|%s}}\n", GetWidgetName(v.name)))
								else
									file:write(string.format(":: {{api|%s}}\n", v.name))
								end
							elseif v.owner.Type == "Event" then
								file:write(string.format(":: {{api|t=e|%s}}\n", v.name))
							end
						end
					else
						file:write(string.format(': <span style="color:gray">%s</span>\n', link))
					end
				end
			else
				for _, name in pairs(Util:SortTable(info[cat_key])) do
					local link = FormatLink(cat_key, name)
					file:write(fs:format(link))
				end
			end
		end
	end
	file:write("|}\n")
	file:close()
end

local function main()
	local refs = GetMixinReferences()
	local owners = GetTableOwners(refs.tables)
	for _, mixin in pairs(mixinTypes) do
		local info = GetMixinRestructured(refs, mixin)
		WriteFile(mixin, info, owners)
	end
end

main()
print("done")
