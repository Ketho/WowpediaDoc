-- crappy table serializer, does just the bare minimum
local function WriteLine(file, s)
	file:write(s.."\n")
end

local function GetFormatValue(s)
	if type(s) == "string" then
		return string.format('"%s"', s)
	elseif type(s) == "table" then
		local t = {}
		for k, v in pairs(s) do
			t[k] = GetFormatValue(v)
		end
		local contents = table.concat(t, ", ")
		return string.format("{%s}", contents)
	else
		return tostring(s)
	end
end

local function WriteTable(tbl, name, path)
	local file = io.open(path, "w")
	WriteLine(file, string.format("local %s = {", name))
	local fs = '%s["%s"] = %s,'
	local level = 1
	local sorted = {}
	for k in pairs(tbl) do
		table.insert(sorted, k)
	end
	table.sort(sorted)
	for _, k in pairs(sorted) do
		local v = tbl[k]
		local formatValue = GetFormatValue(v)
		local tabs = string.rep("\t", level)
		WriteLine(file, fs:format(tabs, k, formatValue))
	end
	WriteLine(file, "}\n")
	WriteLine(file, string.format("return %s", name))
	file:close()
end

return WriteTable
