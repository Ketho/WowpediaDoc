local data = mw.loadData("Module:API_info/group/data")
local m = {}

function m:GetNonPrefixName(name)
	local firstChar = name:sub(1, 1)
	if firstChar == "#" or firstChar == "@" then
		return name:sub(2)
	else
		return name
	end
end

function m:GetApiLookupTable(tbl)
	local t = {}
	for _, group in pairs(tbl) do
		for _, name in pairs(group) do
			name = self:GetNonPrefixName(name)
			t[name] = group
		end
	end
	return t
end
m.data = m:GetApiLookupTable(data)

return m
