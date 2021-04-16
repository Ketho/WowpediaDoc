-- https://wowpedia.fandom.com/wiki/InstanceID#Complete_list
local parser = require("Util/wowtoolsparser")
local patchDBC = require("Projects/DBC/patch")
local output = "Projects/DBC/scripts/map.txt"

local InstanceTypes = {
	[1] = "Dungeon",
	[2] = "Raid",
	[3] = "Battleground",
	[4] = "Arena",
	[5] = "Scenario",
}

local wpExpansion = {
	[1] = "{{Bc-inline}}",
	[2] = "{{Wotlk-inline}}",
	[3] = "{{Cata-inline}}",
	[4] = "{{Mop-inline}}",
	[5] = "{{Wod-inline}}",
	[6] = "{{Legion-inline}}",
	[7] = "{{Bfa-inline}}",
	[8] = "{{Sl-inline}}",
}

local wpLink = {
	[189] = "Scarlet Monastery", -- Scarlet Monastery of Old
	[289] = "Scholomance (Classic)", -- Scholomance OLD
	[309] = "Zul%27Gurub (Classic)", -- Ancient Zul'Gurub
	[489] = "Warsong Gulch", -- Classic Warsong Gulch
	[529] = "Arathi Basin", -- Classic Arathi Basin
	[648] = "Lost Isles", -- LostIsles
	[731] = "The Bomb", -- Stonetalon Bomb
	[951] = "Nexus (instance)#Dragonwrath.2C Tarecgosa.27s Rest", -- Nexus Legendary
	[968] = "Eye of the Storm", -- Rated Eye of the Storm
	[1134] = "Tiger%27s Peak", -- The Tiger's Peak
	[1280] = "Southshore vs Tarren Mill", -- Southshore vs. Tarren Mill
	[1462] = "Masters Promontory", -- Illidans Rock
	[1475] = "Cove of Nashal", -- The Maw of Nashal
	[1502] = "Underbelly", -- Dalaran Underbelly
	[1536] = "Ursoc%27s Lair", -- Ursocs Lair
	[1681] = "Arathi Basin", -- Arathi Basin Winter
	[1809] = "Mechagon Island", -- Mechagnome Island
	[1825] = "Hook Point (arena)", -- Hook Point
	[1904] = "The Stormwind Extraction", -- Stormwind Escape from Stockades
	[1944] = "Thros, the Blighted Lands", -- Thros, The Blighted Lands
	[2117] = "N%27Zoth", -- NZoth
	[2177] = "Brawl: Comp Stomp", -- Arathi Basin Comp Stomp
	[2179] = "Stratholme (pet battle)", -- Stratholme Pet Dungeon
	-- also serves as a whitelist
	[628] = "Isle of Conquest", -- Isle of Conquest (quest)
}

local noLink = {
	[13] = true, -- Art Team Map
	[449] = true, -- Alliance PVP Barracks
	[450] = true, -- Horde PVP Barracks
	[606] = true, -- QA and DVD
	[659] = true, -- Lost Isles Volcano Eruption
	[660] = true, -- Deephome Ceiling
	[661] = true, -- Lost Isles Town in a Box
	[765] = true, -- Krazzworks Attack Zeppelin
	[977] = true, -- Maelstrom Deathwing Fight
	[1135] = true, -- Mogu Island Loot Room
	[1179] = true, -- Warcraft Heroes
	[1268] = true, -- Teron'gor's Confrontation
	[1453] = true, -- Scourge of Northshire
	[1515] = true, -- Huln's War
	[1586] = true, -- Assault on Stormwind
	[1765] = true, -- Warfronts Prototype
	[1779] = true, -- Invasion Points
	[1927] = true, -- Zandalari Flagship
	[1931] = true, -- Lordaeron Blight
	[2103] = true, -- Darkshore Prepatch Darnassian Ship
	[2128] = true, -- Dagger Realm
	[2174] = true, -- Scarlet Halls, Dark Ranger
	[2438] = true, -- SpellPref
}

local patterns = {
	" %- ",
	"%.",
	"%(",
	"%[",
	"%d",
	"_",
	"<",
	" bg",
	" events",
	" hub",
	"alliance",
	"area",
	"delete",
	"development",
	"dungeon",
	"exterior",
	"final",
	"horde",
	"intro",
	"level",
	"phase",
	"playground",
	"quest",
	"scenario",
	"small ",
	"spawnedmo",
	"start",
	"test",
	"transport",
	"zone",
	"zzold",
}

local function IsValidLink(s)
	s = s:lower()
	for _, p in pairs(patterns) do
		if s:find(p) then
			return false
		end
	end
	return true
end

local function main(BUILD)
	local map = parser.ReadCSV("map", {build=BUILD, header=true})
	local patchTbl = patchDBC:GetFirstSeen("map")

	local file = io.open(output, "w")
	local header = '{| class="sortable darktable zebra"\n! ID !! !! Directory !! Map Name !! Type !! Patch\n'
	file:write(header)
	local fs = '|-\n| align="center" | %s || %s || %s || %s || %s || %s\n'
	for l in map:lines() do
		local ID = tonumber(l.ID)
		if ID then
			local dir, name = l.Directory, l.MapName_lang
			local expansion = wpExpansion[tonumber(l.ExpansionID)] or ""
			local instance = InstanceTypes[tonumber(l.InstanceType)] or ""
			local patch = patchTbl[ID] or ""

			local linkName = name
			if wpLink[ID] then
				linkName = string.format("[[%s|%s]]", wpLink[ID], name)
			elseif not noLink[ID] and IsValidLink(name) then
				linkName = string.format("[[:%s]]", name)
			end
			dir = dir:gsub("�", "&#65533;") -- triggers wiki spam filter
			file:write(fs:format(ID, expansion, dir, linkName, instance, patch))
		end
	end
	file:write("|}\n")
	file:close()
end

main()
print("done")
