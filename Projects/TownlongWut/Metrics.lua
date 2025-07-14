local lfs = require("lfs")
local util = require("util")

local PATH = "Projects/TownlongWut"
util:MakeDir(PATH.."/Metrics")

local api_types = {
	"Events",
	"FrameXML",
	"GlobalAPI",
	"Lua",
	"Templates",
}

-- write straight to lua file line by line. probably not a good way to do this
local function ConvertCSV(apitype)
	local file_in = io.open(string.format("%s/%s.csv", PATH, apitype), "r")
	local file_out = io.open(string.format("%s/Metrics/%s.lua", PATH, apitype), "w")
	local t = {}
	local idx = 0
	file_out:write("local data = {\n")
	for l in file_in:lines() do
		local count, name = l:match("(%d+),(.+)")
		if name then
			if tonumber(count) < 3 then
				break
			end
			idx = idx + 1
			t[name] = {tonumber(count), idx}
			file_out:write(string.format('\t["%s"] = {%d, %d},\n', name, idx, count))
		end
	end
	file_out:write("}\n\nreturn data\n")
	file_in:close()
	file_out:close()
	return t
end

local function main()
	local t = {}
	for _, v in pairs(api_types) do
		t[v] = ConvertCSV(v)
	end
	print("TAXIMAP_OPENED", table.unpack(t.Events.TAXIMAP_OPENED)) -- test
end

main()
print("done")

