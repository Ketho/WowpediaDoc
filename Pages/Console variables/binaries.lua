-- note that "AreaTriggers" is in the string table for PTR binaries
local lfs = require("lfs")
local util = require("wowdoc")

local PATH = [[/mnt/d/Prog/World of Warcraft/Binaries]]
util:MakeDir("cache_strings")

local function SortPatchReverse(a, b)
	local major_a, minor_a, patch_a, build_a = a:match("(%d+)%.(%d+)%.(%d+)%.(%d+)")
	local major_b, minor_b, patch_b, build_b = b:match("(%d+)%.(%d+)%.(%d+)%.(%d+)")
	major_a = tonumber(major_a); major_b = tonumber(major_b)
	minor_a = tonumber(minor_a); minor_b = tonumber(minor_b)
	patch_a = tonumber(patch_a); patch_b = tonumber(patch_b)
	build_a = tonumber(build_a); build_b = tonumber(build_b)
	if major_a ~= major_b then
		return major_a > major_b
	elseif minor_a ~= minor_b then
		return minor_a > minor_b
	elseif patch_a ~= patch_b then
		return patch_a > patch_b
	elseif build_a ~= build_b then
		return build_a > build_b
	end
end

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
	table.sort(t, SortPatchReverse)
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
	file:write("local t = {\n")
	local fs = '["%s"]=1,\n'
	for _, k in pairs(util:SortTable(tbl)) do
		file:write(fs:format(k))
	end
	file:write("}\n\nreturn t\n")
	file:close()
end

local function main(blizzres_cvars)
	local cvars = blizzres_cvars[1].var
	local NoStrings = {}
	local t = {}
	local builds = GetBuilds(PATH)
	local prevBuild
	for idx, build in pairs(builds) do
		print("reading", build)
		local exe_path = PATH.."/%s.exe"
		local path = exe_path:format(build)
		local lua_cache = string.format("cache_strings/%s.lua", build)
		local stringsTbl, lcstrings_tbl
		if lfs.attributes(lua_cache) then
			stringsTbl = loadfile(lua_cache)()
			lcstrings_tbl = {}
			for k in pairs(stringsTbl) do
				lcstrings_tbl[k:lower()] = true
			end
		else
			stringsTbl, lcstrings_tbl = GetStrings(path)
			WriteFile(lua_cache, stringsTbl)
		end
		-- filter out cvars that cant be found in strings table in the most recent build
		if idx == 1 then
			for name in pairs(cvars) do
				name = name:lower()
				if not lcstrings_tbl[name] then
					NoStrings[name] = true
				end
			end
		else
			for name in pairs(cvars) do
				if not lcstrings_tbl[name:lower()] and not t[name] and not NoStrings[name:lower()] then
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
	return t
end

return main
