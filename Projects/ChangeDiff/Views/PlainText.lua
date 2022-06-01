local Util = require("Util/Util")

local m = {}

function m:PrintView(changes)
	for _, apiType in pairs(ChangeDiff.apiType_order) do
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
			print("# "..name)
			for _, param in pairs(ChangeDiff.apiTypes[apiType].params) do
				self:GetStructureChanges(param, v[1][param], v[2][param])
			end
		end
		print()
	end
end

local function SortIndex(a, b)
	return a.value.id < b.value.id
end

local ParamIdentifier = {
	Arguments = "arg ",
	Returns = "ret ",
}

function m:GetStructureChanges(param, a, b)
	if not a and b then
		print("  + "..param)
	elseif a and not b then
		print("  -"..param)
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
			if not t_a[tbl.key] then
				print(string.format("  + %s%d: %s", label, tbl.value.id, tbl.key))
			end
		end
		for _, tbl in pairs(Util:SortTableCustom(t_a, SortIndex)) do
			if not t_b[tbl.key] then
				print(string.format("  - %s%d: %s", label, tbl.value.id, tbl.key))
			end
		end
	end
end

return m
