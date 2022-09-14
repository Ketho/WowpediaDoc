-- https://wowpedia.fandom.com/wiki/ItemLocationMixin
local Util = require("Util/Util")
local OUTPUT = "out/page/%s.txt"
local BRANCH = "mainline"
require("Documenter.Load_APIDocumentation.Loader"):main(BRANCH)

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
			s = string.format("{{api|t=w|%s}}", name)
		else
			s = string.format("{{api|%s}}", name)
		end
	elseif cat == "events" then
		s = string.format("{{api|t=e|%s}}", name)
	end
	return s
end

local function WriteFile(mixin, info)
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
			for _, name in pairs(Util:SortTable(info[cat_key])) do
				local link = FormatLink(cat_key, name)
				file:write(fs:format(link))
			end
		end
	end
	file:write("|}\n")
	file:close()
end

local function main()
	local refs = GetMixinReferences()
	for _, mixin in pairs(mixinTypes) do
		local info = GetMixinRestructured(refs, mixin)
		WriteFile(mixin, info)
	end
end

main()
print("done")
