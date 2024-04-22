-- https://github.com/Ketho/BlizzardInterfaceResources/tree/mainline/Resources/GlobalStrings
local parser = require("Util/wago_csv")
local OUT_PATH = "../BlizzardInterfaceResources/Resources/GlobalStrings/%s.lua"

local short  = [[%s = "%s";]]
local quoted = [[_G["%s"] = "%s";]]

local locales = {
	"deDE",
	"enUS", -- same as enGB
	"esES", "esMX",
	"frFR",
	"itIT",
	"koKR",
	"ptBR", -- same as ptPT
	"ruRU",
	"zhCN",	"zhTW",
}

local classic_flavors = {
	wrath = true,
	vanilla = true,
}

local function IsValidTableKey(s)
	return not s:find("-") and not s:find("^%d")
end

local validEscapes = {
	["\\"] = true,
	["\""] = true,
	["n"] = true,
	["r"] = true,
	["t"] = true,
}

local function FixEscapes(s)
	local matches = {}
	for v in s:gmatch([[\(.)]]) do
		if not validEscapes[v] and not matches[v] then
			matches[v] = true
			-- it appears these invalid escapes are unneeded
			-- https://github.com/Stanzilla/WoWUIBugs/issues/238
			if v == ")" then
				s = s:gsub([[\%]]..v, v)
			elseif v == "%" then
				s = s:gsub([[\%]]..v, "%"..v)
			else
				s = s:gsub([[\]]..v, v)
			end
		end
	end
	return s
end

local function GlobalStrings(path, options)
	local globalstrings = parser:ReadCSV("globalstrings", options)
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

	print("writing "..path)
	local file = io.open(path, "w")
	for _, tbl in pairs(stringsTable) do
		local key, value = tbl.BaseTag, tbl.TagText
		value = value:gsub("\n", [[\n]]) -- newline in csv
		value = value:gsub([[\32]], " ") -- space char
		value = value:gsub([[\"]], [["]]) -- unescape any quotes
		value = value:gsub([["]], [[\"]]) -- before escaping quotes
		value = FixEscapes(value)
		if key == "KEY_BACKSLASH" or key:find("^KEY_OEM") then -- single backslash
			value = value:gsub([[\]], [[\\]])
		end
		if options.locale == "esES" and key == "ABANDON_QUEST_CONFIRM" then
			value = [[¿Abandonar \"%s\"?]] -- ""¿Abandonar \%s\?""
		end
		local fs = IsValidTableKey(key) and short or quoted
		file:write(fs:format(key, value), "\n")
	end
	file:close()
end

local function WriteLocales(options)
	for _, locale in pairs(locales) do
		-- if not (locale == "itIT" and classic_flavors[options.flavor]) then
		local path = OUT_PATH:format(locale)
		options.locale = locale
		GlobalStrings(path, options)
		-- end
	end
	options.locale = nil
end

return WriteLocales
