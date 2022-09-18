local lfs = require "lfs"
local Util = require("Util.Util")
local BRANCH = "mainline"
-- local NoStrings = require("Projects.GetStrings.NoStrings")
Util:MakeDir("cache_txt")

local builds = {
	"9.2.7.45338",
	"9.0.1.36577",
	"8.0.1.27101",
	"7.0.3.22248",
	"6.0.2.19027",
	"5.0.3.15890",
	"4.1.0.14007",
	"3.0.1.8874",
	"2.0.1.6180",
	"1.0.0.3980",
}

-- some cvars have a different casing in older builds e.g. ffxDeath
local function GetStrings(path)
	local t = {}
	local file = io.open(path, "rb")
	local data = file:read("a")
	for word in data:gmatch("[%w_]+") do
		t[word:lower()] = true
	end
	file:close()
	return t
end

-- for debug purpose
local function WriteFile(path, tbl)
	print("writing to", path)
	local file = io.open(path, "w")
	for _, k in pairs(Util:SortTable(tbl)) do
		file:write(k.."\n")
	end
	file:close()
end

local function GetCVars(branch)
	return Util:DownloadAndRun(
		string.format("cache_lua/CVars_%s", branch),
		string.format("https://github.com/Ketho/BlizzardInterfaceResources/blob/%s/Resources/CVars.lua", branch)
	)
end

local function main()
	local cvars = GetCVars(BRANCH)[1].var
	local PATH = [[D:\Prog\World of Warcraft\Binaries\%s.exe]]
	local NoStrings = {}
	local t = {}
	for idx, build in pairs(builds) do
		print("reading", build)
		local path = PATH:format(build)
		local dump = GetStrings(path)
		-- filter out cvars that cant be found in strings table in the most recent build
		if idx == 1 then
			for name in pairs(cvars) do
				name = name:lower()
				if not dump[name] then
					NoStrings[name] = true
				end
			end
		else
			local txt_path = string.format("cache_txt/%s.txt", build)
			if not lfs.attributes(txt_path) then
				WriteFile(txt_path, dump)
			end
			for name in pairs(cvars) do
				if not dump[name:lower()] and not t[name] and not NoStrings[name:lower()] then
					t[name] = build:match("^%d+")..".x"
				end
			end
			-- cvars that were added in 1.0.0
			if idx == #builds then
				for name in pairs(cvars) do
					if not t[name] and not NoStrings[name:lower()] then
						t[name] = "1.0"
					end
				end
			end
		end
	end
	local out_path = "KethoWowpedia/patch/cvar.lua"
	print("writing to ", out_path)
	local file = io.open(out_path, "w")
	file:write("KethoWowpedia.patch.cvar = {\n")
	for _, k in pairs(Util:SortTable(t, Util.SortNocase)) do
		file:write(string.format('\t["%s"] = "%s",\n', k, t[k]))
	end
	file:write("}\n")
	file:close()
end

main()
print("done")
