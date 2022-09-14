local Util = require("Util.Util")

local function GetStrings(path)
	local t = {}
	local file = io.open(path, "rb")
	local data = file:read("a")
	for word in data:gmatch("[%w_]+") do
		t[word] = true
	end
	file:close()
	return t
end

local function WriteFile(path, tbl)
	print("writing to", path)
	local file = io.open(path, "w")
	for _, k in pairs(Util:SortTable(tbl)) do
		file:write(k.."\n")
	end
	file:close()
end

local function main()
	local strings = GetStrings([[E:\Game\World of Warcraft\_retail_\Wow.exe]])
	WriteFile("cache_lua/strings.txt", strings)
end

main()
print("done")
