-- https://github.com/Ketho/BlizzardInterfaceResources/blob/live/Resources/GlobalStrings.lua
local parser = require "Util.wowtoolsparser"
--local OUT_PATH = "out/GlobalStrings.lua"
local OUT_PATH = "../BlizzardInterfaceResources/Resources/GlobalStrings.lua"

local short = '%s = "%s";'
local full = '_G["%s"] = "%s";'

local slashStrings = {
	KEY_BACKSLASH = function(s) return s:sub(1, 2) == "9." end, -- broken in 9.1.0
	CHATLOGENABLED = function(s) return s:sub(1, 3) == "9.0" end, -- broken in 9.0.5
	--COMBATLOGENABLED = true,
}

local override = {
	-- https://wow.tools/dbc/?dbc=globalstrings#search=PARTY_PLAYER_CHROMIE_TIME_FMT
	PARTY_PLAYER_CHROMIE_TIME_FMT = [[%s\n\n\\%s]], -- 9.0.1 (35256)
}

local function IsValidTableKey(s)
	return not s:find("-") and not s:find("^%d")
end

local function GlobalStrings(options)
	options = options or {}
	options.header = true
	-- filter and sort globalstrings
	local globalstrings, usedBuild = parser:ReadCSV("globalstrings", options)
	local stringsTable = {}
	for line in globalstrings:lines() do
		local flags = tonumber(line.Flags)
		if flags and flags&0x1 > 0 then
			table.insert(stringsTable, {
				BaseTag = line.BaseTag,
				TagText = line.TagText_lang
			})
		end
	end
	table.sort(stringsTable, function(a, b)
		return a.BaseTag < b.BaseTag
	end)

	print("writing "..OUT_PATH)
	local file = io.open(OUT_PATH, "w")
	for _, tbl in pairs(stringsTable) do
		local key, value = tbl.BaseTag, tbl.TagText
		value = value:gsub('\\32', ' ') -- space char
		-- unescape any quotes before escaping quotes
		value = value:gsub('\\\"', '"')
		value = value:gsub('"', '\\\"')
		if slashStrings[key] and slashStrings[key](usedBuild) then
			value = value:gsub("\\", "\\\\")
		end
		if override[key] then
			value = override[key]
		end

		-- check if the key is proper short table syntax
		local fs = IsValidTableKey(key) and short or full
		file:write(fs:format(key, value), "\n")
	end
	file:close()
	print("finished")
end

return GlobalStrings
