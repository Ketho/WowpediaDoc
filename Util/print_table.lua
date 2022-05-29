local function FormatValue(v)
	if type(v) == "string" then
		v = v:gsub([["]], [[\"]])
		return string.format([["%s"]], v)
	else
		return v
	end
end

local function PrintKeyValue(k, v, space)
	print(string.format("%s[%s] = %s,", space, FormatValue(k), FormatValue(v)))
end

local function explode(t, level)
	level = level or 0
	local space = string.rep(" ", level*4)
	for k, v in pairs(t) do
		if type(v) == "table" then
			print(string.format("%s[%s] = {", space, FormatValue(k)))
			explode(v, level+1)
			print(space.."},")
		else
			PrintKeyValue(k, v, space)
		end
	end
end

return explode
