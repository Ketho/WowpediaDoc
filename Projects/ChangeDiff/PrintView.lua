local Util = require("Util/Util")

local m = {}
local p = ChangeDiff

local wp_api = {
	Function = "a",
	Event = "e",
}

function m:PrintView(changes, isWiki)
	for _, apiType in pairs(p.apiType_order) do
		print(apiType)
		local t = changes[apiType]
		for _, name in pairs(Util:SortTable(t[1])) do
			print("+ "..name)
		end
		for _, name in pairs(Util:SortTable(t[2])) do
			print("- "..name)
		end
		for _, name in pairs(Util:SortTable(t[3])) do
			local v = t[3][name]
			if v[1].Type == "Enumeration" then
				name = "Enum."..name
			end
			if isWiki then
				if wp_api[apiType] then
					print(string.format("{{api|t=%s|%s}}", wp_api[apiType], name))
				else
					print(name)
				end
			else
				print("# "..name)
			end
			for _, param in pairs(p.apiTypes[apiType].params) do
				self:PrintParamChanges(param, v[1][param], v[2][param], isWiki)
			end
		end
		print()
	end
end

local ParamIdentifier = {
	Arguments = "arg ",
	Returns = "ret ",
}

local fs_info = {
	plain = {
		add              = '  + %s%d: %s',
		remove           = '  - %s%d: %s',
		modified_type    = '  # %s%d: %s, Type: %s -> %s',
		modified_nilable = '  # %s%d: %s, Nilable: %s -> %s',
	},
	wiki = {
		add              = '  + %s%d: <font color="#00b400">%s</font>',
		remove           = '  - %s%d: <font color="#ff6767">%s</font>',
		modified_type    = '  # %s%d: <font color="#ecbc2a">%s</font>, Type: %s -> %s',
		modified_nilable = '  # %s%d: <font color="#ecbc2a">%s</font>, Nilable: %s -> %s',
	},
}

local function SortIndex(a, b)
	return a.value.id < b.value.id
end

function m:PrintParamChanges(param, a, b, isWiki)
	local fs = isWiki and fs_info.wiki or fs_info.plain
	if not a and b then
		print("  + "..param)
	elseif a and not b then
		print("  - "..param)
	elseif a and b then
		local label = ParamIdentifier[param] or ""
		local t_a, t_b = {}, {}
		for k, v in pairs(a) do
			t_a[v.Name] = {id=k, info=v}
		end
		for k, v in pairs(b) do
			t_b[v.Name] = {id=k, info=v}
		end
		for _, tbl in pairs(Util:SortTableCustom(t_b, SortIndex)) do
			local left = t_a[tbl.key]
			local right = tbl.value.info
			if not left then
				print(string.format(fs.add, label, tbl.value.id, tbl.key))
			else
				if right.Type ~= left.info.Type then
					print(string.format(fs.modified_type, label, tbl.value.id, tbl.key, left.info.Type, right.Type))
				end
				if right.Nilable ~= left.info.Nilable then
					print(string.format(fs.modified_nilable, label, tbl.value.id, tbl.key, left.info.Nilable, right.Nilable))
				end
			end
		end
		for _, tbl in pairs(Util:SortTableCustom(t_a, SortIndex)) do
			if not t_b[tbl.key] then
				print(string.format(fs.remove, label, tbl.value.id, tbl.key))
			end
		end
	end
end

return m
