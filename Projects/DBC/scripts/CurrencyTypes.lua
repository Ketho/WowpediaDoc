-- https://wowpedia.fandom.com/wiki/CurrencyID
local parser = require("Util/wowtoolsparser")
local Util = require("Util/Util")
local patch = require("Projects/DBC/patch")
local output = "out/page/CurrencyTypes.txt"

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
	"%(",
	"Reservoir Anima%-",
	"Redeemed Soul%-",
	"Sanctum Architect%-",
	"Sanctum Anima Weaver%-",
}

local broken = {
	["5.4.7"] = true,
	["5.4.8"] = true,
}

local function GetPatchData(name)
	local versions = parser:GetVersions(name)
	local patches = {}
	local found = {}
	for _, v in pairs(versions) do
		local major = Util:GetPatchVersion(v)
		if major == "2.5.2" then
			break
		elseif not found[major] and not broken[major] then
			found[major] = true
			table.insert(patches, v)
		end
	end
	table.sort(patches)
	local firstSeen = patch:GetFirstSeen(name, patches)
	return firstSeen
end

local function IsValidLink(id, name, categoryID)
	if nolink[id] then
		return false
	elseif categoryID == 248 then
		return false
	end
	for _, v in pairs(ignoredStrings) do
		if name:find(v) then
			return false
		end
	end
	return true
end

local header = '{| class="sortable darktable zebra"\n! ID !! Name || Category || Patch\n'
local fs = '|-\n| align="center" | %d || %s || %s || %s\n'

local function main(BUILD)
	local dbc_currencytypes = parser:ReadCSV("currencytypes", {header=true, build=BUILD})
	local dbc_currencycategory = parser:ReadCSV("currencycategory", {header=true, build=BUILD})
	print("writing to "..output)
	local file = io.open(output, "w")
	local patchData = GetPatchData("currencytypes")

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
			if IsValidLink(ID, l.Name_lang, categoryID) then
				if wplink[ID] then
					nameText = string.format("[[%s|%s]]", wplink[ID], l.Name_lang)
				elseif not nolink[ID] then
					nameText = string.format("[[:%s]]", l.Name_lang)
				end
			end
			local categoryText = string.format('<span title="ID %d">%s</span>', categoryID, categories[categoryID])
			local seen = patchData[ID] and Util:GetPatchVersion(patchData[ID]) or ""
			file:write(fs:format(ID, nameText, categoryText, seen))
		end
	end
	file:write("|}\n")
	file:close()
end

main()
print("done")
