local lfs = require("lfs")
local util = require("util")
local PATH = [[D:\Prog\World of Warcraft\Binaries]]
local BRANCH = "mainline"
util:MakeDir("cache_txt")

local function GetBuilds(path)
	local t = {}
	for fileName in lfs.dir(path) do
		if fileName ~= "." and fileName ~= ".." then
			local exe = fileName:match("(.+)%.exe")
			if exe then
				table.insert(t, exe)
			end
		end
	end
	table.sort(t, function(a, b)
		local build_a = a:match("(%d+)$")
		local build_b = b:match("(%d+)$")
		return tonumber(build_a) > tonumber(build_b)
	end)
	return t
end

-- some cvars have a different casing in older builds e.g. ffxDeath
local function GetStrings(path)
	local t, t_lower = {}, {}
	local file = io.open(path, "rb")
	local data = file:read("a")
	for word in data:gmatch("[%w_]+") do
		t[word] = true
		t_lower[word:lower()] = true
	end
	file:close()
	return t, t_lower
end

-- for debug purpose
local function WriteFile(path, tbl)
	print("writing to", path)
	local file = io.open(path, "w")
	for _, k in pairs(util:SortTable(tbl)) do
		file:write(k.."\n")
	end
	file:close()
end

local function GetCVars(branch)
	return util:DownloadAndRun(
		string.format("cache_lua/CVars_%s", branch),
		string.format("https://github.com/Ketho/BlizzardInterfaceResources/blob/%s/Resources/CVars.lua", branch)
	)
end

local function main()
	local cvars = GetCVars(BRANCH)[1].var
	local NoStrings = {}
	local t = {}
	local builds = GetBuilds(PATH)
	local prevBuild
	for idx, build in pairs(builds) do
		print("reading", build)
		local exe_path = PATH.."/%s.exe"
		local path = exe_path:format(build)
		local t_normal, dump = GetStrings(path)
		local txt_path = string.format("cache_txt/%s.txt", build)
		if not lfs.attributes(txt_path) then
			WriteFile(txt_path, t_normal)
		end
		-- filter out cvars that cant be found in strings table in the most recent build
		if idx == 1 then
			for name in pairs(cvars) do
				name = name:lower()
				if not dump[name] then
					NoStrings[name] = true
				end
			end
		else
			for name in pairs(cvars) do
				if not dump[name:lower()] and not t[name] and not NoStrings[name:lower()] then
					local patch, buildversion = prevBuild:match("^(%d+%.%d+%.%d+)%.(%d+)")
					if tonumber(buildversion) >= 19034 then -- 6.0.2.19034
						t[name] = patch
					else
						t[name] = prevBuild:match("^%d+")..".x"
					end
				end
			end
			-- cvars that were added in 1.0.0
			if idx == #builds then
				for name in pairs(cvars) do
					if not t[name] and not NoStrings[name:lower()] then
						t[name] = "1.0.0"
					end
				end
			end
		end
		prevBuild = build
	end
	local out_path = "KethoWowpedia/patch/cvar.lua"
	print("writing to ", out_path)
	local file = io.open(out_path, "w")
	file:write("KethoWowpedia.patch.cvar = {\n")
	for _, k in pairs(util:SortTable(t, util.SortNocase)) do
		file:write(string.format('\t["%s"] = "%s",\n', k, t[k]))
	end
	file:write("}\n")
	file:close()
end

main()
print("done")
