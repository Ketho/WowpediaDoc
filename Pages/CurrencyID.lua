-- https://wowpedia.fandom.com/wiki/CurrencyID
local util = require("util")
local parser = require("util.wago")
local dbc_patch = require("Projects/DBC/DBC_patch")
local OUTPUT = "out/page/CurrencyID.txt"

local wplink = {
	[1101] = "Oil (currency)",
	[1540] = "Wood (Warfronts)",
	[1541] = "Iron (Warfronts)",
	[1587] = "Legionfall War Supplies",
	[1599] = "7th Legion (faction)",
	[1739] = "Waveblade Ankoan",
	[1745] = "Neri Sharpfin",
	[1746] = "Vim Brineheart",
	[1747] = "Poen Gillbrack",
	[1748] = "Bladesman Inowari",
	[1749] = "Hunter Akana",
	[1750] = "Farseer Ori",
	[1829] = "Renown",
	[1830] = "Renown",
	[1831] = "Renown",
	[1832] = "Renown",
	[1859] = "Reservoir Anima",
	[1860] = "Reservoir Anima",
	[1861] = "Reservoir Anima",
	[1862] = "Reservoir Anima",
	[1863] = "Redeemed Soul",
	[1864] = "Redeemed Soul",
	[1865] = "Redeemed Soul",
	[1866] = "Redeemed Soul",
	[1867] = "Sanctum Architect",
	[1868] = "Sanctum Architect",
	[1869] = "Sanctum Architect",
	[1870] = "Sanctum Architect",
	[1871] = "Sanctum Anima Weaver",
	[1872] = "Sanctum Anima Weaver",
	[1873] = "Sanctum Anima Weaver",
	[1874] = "Sanctum Anima Weaver",
	[2002] = "Renown",
	[2021] = "Renown",
	[2087] = "Renown",
	[2088] = "Renown",
}

local nolink = {
	[104] = true, -- Honor Points DEPRECATED
	[181] = true, -- Honor Points DEPRECATED2
	[483] = true, -- Conquest Arena Meta
	[484] = true, -- Conquest Rated BG Meta
	[692] = true, -- Conquest Random BG Meta
	[830] = true, -- n/a
	[897] = true, -- UNUSED
	[1585] = true, -- Account Wide Honor
	[1703] = true, -- PVP Season Rated Participation Currency
	[1743] = true, -- Fake Anima for Quest Tracking
	[1761] = true, -- Enemy Damage
	[1762] = true, -- Enemy Health
	[1763] = true, -- Deaths
	[1802] = true, -- Shadowlands PvP Weekly Reward Progress
	[1877] = true, -- Bonus Experience
	[1891] = true, -- Honor from Rated
	[1902] = true, -- 9.1 - Torghast XP - Prototype - LJS
	[1903] = true, -- Invisible Reward
}

local ignoredStrings = {
	"zzold",
	" Test ",
	" %- ",
	"%(",
	"Reservoir Anima%-",
	"Redeemed Soul%-",
	"Sanctum Architect%-",
	"Sanctum Anima Weaver%-",
}

local function IsValidName(id, name, categoryID)
	if nolink[id] then
		return false
	elseif categoryID == 248 then -- Torghast UI (Hidden)
		return false
	end
	for _, v in pairs(ignoredStrings) do
		if name:find(v) then
			return false
		end
	end
	return true
end

local patch_override = {
	["7.3.0"] = "6.x / 7.x",
}

local header = '{| class="sortable darktable zebra col1-center"\n! ID !! Name || Category || Patch\n'
local fs = '|-\n| %d || %s || %s || %s\n'

local function main(options)
	options = util:GetFlavorOptions(options)
	local dbc_currencytypes = parser:ReadCSV("currencytypes", options)
	local dbc_currencycategory = parser:ReadCSV("currencycategory", options)
	local patchData = dbc_patch:GetPatchData("currencytypes", options)
	local file = io.open(OUTPUT, "w")

	local categories = {}
	for l in dbc_currencycategory:lines() do
		local ID = tonumber(l.ID)
		if ID then
			categories[ID] = l.Name_lang
		end
	end

	file:write(header)
	for l in dbc_currencytypes:lines() do
		local ID = tonumber(l.ID)
		if ID then
			local categoryID = tonumber(l.CategoryID)
			local nameText = l.Name_lang
			if wplink[ID] then
				nameText = string.format("[[%s|%s]]", wplink[ID], l.Name_lang)
			elseif IsValidName(ID, l.Name_lang, categoryID) then
				nameText = string.format("[[:%s]]", l.Name_lang)
			end
			local categoryText = string.format('<span title="ID %d">%s</span>', categoryID, categories[categoryID])
			local patch = util:GetPatchText(patchData, ID, patch_override)
			file:write(fs:format(ID, nameText, categoryText, patch))
		end
	end
	file:write("|}\n")
	file:close()
	print("written "..OUTPUT)
end

main()
print("done")
