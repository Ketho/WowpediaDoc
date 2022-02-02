-- https://wowpedia.fandom.com/wiki/FactionID
local Util = require "Util/Util"
local parser = require "Util/wowtoolsparser"
local dbc_patch = require("Projects/DBC/DBC_patch")
local OUTPUT = "out/page/FactionID.txt"

local function isValidLink(s)
	if s:find("%(") then -- Paragon, Season
		return false
	elseif s:find("DEPRECATED") then
		return false
	elseif s:find("^Test") then
		return false
	elseif s:find("_") then
		return false
	elseif s:find(" %- ") then
		return false
	end
	return true
end

local invalidFactions = {
	-- has a description
	[1357] = true, -- Nomi
	[2063] = true, -- Arne Test - Paragon Reputation Stormwind
}

-- these IDs dont seem to return values
local function isValidName(s, id)
	if invalidFactions[id] then
		return false
	elseif s:find("^GarInvasion_") then
		return false
	elseif s:find("%(Paragon") then
		return false
	end
	return true
end

-- https://github.com/kevinclement/SimpleArmory/blob/master/dataimporter/factions.py
local removedFaction = {
	-- never implemented
	[1888] = true, -- Jandvik Vryul
	[2111] = true, -- Zandalari Dinosaurs
	[1351] = true, -- The Brewmasters
	[1416] = true, -- Akama's Trust
	[1440] = true, -- Darkspear Rebellion
}

local factionFixes = {
	[589] = "{{Alliance}}", -- Wintersaber Trainers: seems flagged as Horde
	[809] = "{{Alliance}}", -- Shen'dralar: no flags
	[1085] = "{{Horde}}", -- Warsong Offensive: flagged as alliance
}

-- flag1 appears to be used for cities
-- not sure if I'm missing some easy bitwise comparing
local function GetFactionIcon(options, id, flag0, flag1)
	local v1, v2
	if options.flavor == "classic" then
		v1 = 690
		v2 = 1101
	else
		v1 = 0xAA2AAAAA4E0AB3B2 -- -6184943489809468494
		v2 = 0x55155555B1354C4D -- 6130900294268439629
	end
	if factionFixes[id] then
		return factionFixes[id]
	elseif flag1 == v1 or flag0 == v2 then
		return "{{Alliance}}"
	elseif flag1 == v2 or flag0 == v1 then
		return "{{Horde}}"
	end
end

local function main(options)
	options = Util:GetFlavorOptions(options)
	options.initial = false
	local faction = parser:ReadCSV("faction", options)
	local patchData = dbc_patch:GetPatchData("faction", options)

	local file = io.open(OUTPUT, "w")
	local faction_parents = {}
	local faction_names = {}
	for l in faction:lines() do
		local ID = tonumber(l.ID)
		local name = l.Name_lang
		if ID then
			faction_names[ID] = name
			local parentFactionID = tonumber(l.ParentFactionID)
			if parentFactionID > 0 then
				faction_parents[parentFactionID] = true
			end
		end
	end

	file:write('{| class="sortable darktable zebra col1-center col2-center col3-center"\n')
	file:write("! ID !! !! !! Name !! Parent Faction !! Patch")
	local fs = "\n|-\n| %d || %s || %s || %s || %s || %s"
	local friendshipIcon = "[[File:Achievement_reputation_06.png|18px]]"

	-- lazy way to read it twice
	faction = parser:ReadCSV("faction", options)
	print("writing to "..OUTPUT)
	for l in faction:lines() do
		local ID = tonumber(l.ID)
		if ID then
			local name = l.Name_lang
			local desc = l.Description_lang
			local repIndex = tonumber(l.ReputationIndex)
			local parentFactionID = tonumber(l.ParentFactionID)
			local friendshipID = tonumber(l.FriendshipRepID)
			local flags = l.Flags
			local repracemask0 = tonumber(l["ReputationRaceMask[0]"])
			local repracemask1 = tonumber(l["ReputationRaceMask[1]"])

			if repIndex > 0 and isValidName(name, ID) then
				local isValidParent = parentFactionID == 0 and faction_parents[ID]
				if parentFactionID > 0 or isValidParent or #desc > 0 then
					local factionIcon
					if removedFaction[ID] then
						factionIcon = "❌"
					else
						factionIcon = GetFactionIcon(options, ID, repracemask0, repracemask1) or ""
					end
					local friendText = friendshipID > 0 and friendshipIcon or ""
					local nameText = name
					if isValidLink(name) then
						nameText = string.format("[[:%s]]", name)
					end
					local parentName = ""
					if parentFactionID > 0 then
						local displayName = faction_names[parentFactionID] or "unknown"
						parentName = string.format('<span title="%s">%s</span>', parentFactionID, displayName)
					end
					local seen = patchData[ID] and Util:GetPatchVersion(patchData[ID]) or ""
					file:write(fs:format(ID, factionIcon, friendText, nameText, parentName, seen))
				end
			end
		end
	end
	file:write("\n|}\n")
	file:close()
end

main() -- ["ptr", "mainline", "classic"]
print("done")

--[[
-- top level parents
-- if parents[ID] and parentFactionID == 0 then
-- 	print(ID, repIndex, parentFactionID, name)
-- end
ID		repIdx	parent	Name
949     85      0       Test Faction 1
980     43      0       The Burning Crusade
1097    89      0       Wrath of the Lich King
1118    96      0       Classic
1162    111     0       Cataclysm
1169    115     0       Guild
1245    145     0       Mists of Pandaria
1444    230     0       Warlords of Draenor
1834    146     0       Legion
2104    263     0       Battle for Azeroth
2414    322     0       Shadowlands

-- factions with parentid 0 which dont have any children
ID		repIdx	parent	Name
46      29      0        Blacksmithing - Armorsmithing
83      23      0       Leatherworking - Elemental
86      22      0       Leatherworking - Dragonscale
289     30      0        Blacksmithing - Weaponsmithing
549     24      0       Leatherworking - Tribal
550     26      0       Engineering - Goblin
551     25      0       Engineering - Gnome
569     33      0       Blacksmithing - Hammersmithing
570     31      0       Blacksmithing - Axesmithing
571     32      0       Blacksmithing - Swordsmithing
574     34      0       Caer Darrow
949     85      0       Test Faction 1
1005    68      0       Friendly, Hidden
1136    100     0       Tranquillien Conversion
1137    101     0       Wintersaber Conversion
1154    102     0       Silver Covenant Conversion
1155    103     0       Sunreavers Conversion
1357    191     0       Nomi
1433    227     0       Monster, Enforced Neutral For Force Reaction
2063    214     0       Arne Test - Paragon Reputation Stormwind
2396    313     0       Honeyback Drone
2397    314     0       Honeyback Hivemother
2398    315     0       Honeyback Harvester
2431    330     0       Owen Test
]]