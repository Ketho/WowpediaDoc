-- https://wowpedia.fandom.com/wiki/InstanceID#Complete_list
local parser = require("Util/wowtoolsparser")
local Util = require("Util/Util")
local dbc_patch = require("Projects/DBC/patch")
local output = "out/page/Map.txt"

local InstanceTypes = {
	--[0] = "Not Instanced",
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

local nolink = {
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
	[2267] = true, -- city
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

local function GetPatchData(name)
	local versions = parser:GetVersions(name)
	local patches = {}
	local found = {}
	for _, v in pairs(versions) do
		local major = Util:GetPatchVersion(v)
		if major == "3.3.3" then -- status 400
			break
		elseif not found[major] then
			found[major] = true
			table.insert(patches, v)
		end
	end
	table.sort(patches)
	local firstSeen = dbc_patch:GetFirstSeen(name, patches)
	return firstSeen
end

local function main(BUILD)
	local map = parser:ReadCSV("map", {header=true, build=BUILD})
	local patchData = GetPatchData("map")

	local file = io.open(output, "w")
	file:write('{| class="sortable darktable zebra"\n! ID !! !! !! Directory !! Map Name !! Type !! Patch\n')
	local fs = '|-\n| align="center" | %s || %s || %s || %s || %s || %s || %s\n'
	for l in map:lines() do
		local ID = tonumber(l.ID)
		if ID then
			local expansion = wpExpansion[tonumber(l.ExpansionID)] or ""
			local flags = l["Flags[0]"]
			local devmap = flags&0x2 > 0 and "[[File:ProfIcons_engineering.png|16px|link=]]" or ""

			local dir = l.Directory:gsub("�", "&#65533;") -- triggers wiki spam filter otherwise
			if dir == l.ID then
				dir = ""
			end

			local nameText
			if wpLink[ID] then
				nameText = string.format("[[%s|%s]]", wpLink[ID], l.MapName_lang)
			elseif not nolink[ID] and IsValidLink(l.MapName_lang) then
				nameText = string.format("[[:%s]]", l.MapName_lang)
			else
				nameText = l.MapName_lang
			end
			local instance = InstanceTypes[tonumber(l.InstanceType)] or ""
			local patch = patchData[ID] and Util:GetPatchVersion(patchData[ID]) or ""
			file:write(fs:format(ID, expansion, devmap, dir, nameText, instance, patch))
		end
	end
	file:write("|}\n")
	file:close()
end

main()
print("done")
