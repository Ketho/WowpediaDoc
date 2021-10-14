-- https://wowpedia.fandom.com/wiki/DungeonEncounterID
local parser = require("Util/wowtoolsparser")
local Util = require("Util/Util")
local dbc_patch = require("Projects/DBC/patch")
local output = "out/page/DungeonEncounter.txt"

local encounterLink = {
	[526] = "Keristrasza (tactics)",
	[527] = "Keristrasza (tactics)",
	[594] = "Gahz'rilla",
	[608] = "Illidari Council",
	[1029] = "Cho'gall (tactics)",
	[1032] = "Valiona and Theralion",
	[1103] = "Blood-Queen Lana'thel (tactics)",
	[1662] = "Aarux",
	[1667] = "Ghamoo-Ra",
	[1805] = "Hymdall (tactics)",
	[1824] = "Helya (tactics)",
	[1872] = "Elisande (tactics)",
	[1873] = "Il'gynoth",
	[2004] = "Salramm the Fleshcrafter",
	[2005] = "Mal'Ganis (tactics)",
	[2008] = "Helya (Trial of Valor tactics)",
	[2011] = "Keristrasza (tactics)",
	[2021] = "The Black Knight (tactics)",
	[2059] = "Sigryn",
	[2079] = "Dark Keeper Aedis",
	[2096] = "Harlan Sweete",
	[2108] = "Mogul Razdunk (tactics)",
	[2145] = "Zul, Reborn",
	[2272] = "King Rastakhan (tactics)",
	[2273] = "Uu'nat",
	[2276] = "High Tinker Mekkatorque (tactics)",
}

local mapLink = {
	[784] = "Zul'Gurub (Classic)",
	[785] = "Zul'Gurub (Classic)",
	[786] = "Zul'Gurub (Classic)",
	[787] = "Zul'Gurub (Classic)",
	[788] = "Zul'Gurub (Classic)",
	[789] = "Zul'Gurub (Classic)",
	[790] = "Zul'Gurub (Classic)",
	[791] = "Zul'Gurub (Classic)",
	[792] = "Zul'Gurub (Classic)",
	[793] = "Zul'Gurub (Classic)",
	[444] = "Scarlet Monastery Graveyard",
	[446] = "Scarlet Monastery Library",
	[447] = "Scarlet Monastery Library",
	[448] = "Scarlet Monastery Armory",
	[449] = "Scarlet Monastery Cathedral",
	[450] = "Scarlet Monastery Cathedral",
	[451] = "Scholomance (Classic)",
	[452] = "Scholomance (Classic)",
	[453] = "Scholomance (Classic)",
	[454] = "Scholomance (Classic)",
	[455] = "Scholomance (Classic)",
	[456] = "Scholomance (Classic)",
	[457] = "Scholomance (Classic)",
	[458] = "Scholomance (Classic)",
	[459] = "Scholomance (Classic)",
	[460] = "Scholomance (Classic)",
	[461] = "Scholomance (Classic)",
	[462] = "Scholomance (Classic)",
	[463] = "Scholomance (Classic)",

}

local noEncounter = {
	[1348] = true, -- Omar the Test Dragon
	[2443] = true, -- Test - Fatescribe
	[2494] = true, -- Test Chest
	[2495] = true, -- 9.1 Desmotaeron - World Boss

}

-- uses l.MapID
local noMap = {
	--[189] = true, -- Scarlet Monastery of Old
	--[289] = true, -- Scholomance OLD
	--[309] = true, -- Ancient Zul'Gurub
	[598] = true, -- Sunwell Fix (Unused)
	[605] = true, -- Development Land (non-weighted textures)
	[1457] = true, -- Test Dungeon
	[1689] = true, -- The Eye of Eternity - Mage Class Mount
	[1703] = true, -- Halls of Valor - Scenario
	[2360] = true, -- Sinfall Scenario
}

local function GetPatchData(name)
	local versions = parser:GetVersions(name)
	local patches = {}
	local found = {}
	for _, v in pairs(versions) do
		local major = Util:GetPatchVersion(v)
		if major == "2.5.2" then
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

local function IsValidEncounterLink(id, name)
	if noEncounter[id] then
		return false
	elseif name:find("[%[(]") then
		return false
	end
	return true
end

local function IsValidMapLink(id, name)
	if noMap[id] then
		return false
	elseif name:find("Scenario") then
		return false
	end
	return true
end

local header = '{| class="sortable darktable zebra"\n! ID !! Name !! Map || Patch\n'
local fs = '|-\n| align="center" | %d || %s || %s || %s\n'

local function main(BUILD)
	local dbc_dungeonencounter = parser:ReadCSV("dungeonencounter", {header=true, build=BUILD})
	local dbc_map = parser:ReadCSV("map", {header=true, build=BUILD})
	print("writing to "..output)
	local file = io.open(output, "w")
	local patchData = GetPatchData("dungeonencounter")

	local mapNames = {}
	for l in dbc_map:lines() do
		local ID = tonumber(l.ID)
		if ID then
			mapNames[ID] = l.MapName_lang
		end
	end

	file:write(header)
	for l in dbc_dungeonencounter:lines() do
		local ID = tonumber(l.ID)
		if ID then
			local encounterName = l.Name_lang
			local nameText
			if encounterLink[ID] then
				nameText = string.format("[[%s|%s]]", encounterLink[ID], encounterName)
			elseif IsValidEncounterLink(ID, encounterName) then
				nameText = string.format("[[:%s]]", encounterName)
			else
				nameText = encounterName
			end

			local mapID = tonumber(l.MapID)
			local mapName = mapNames[mapID]
			local mapText
			if mapLink[ID] then
				mapText = string.format("[[%s|%s]]", mapLink[ID], mapName)
			elseif IsValidMapLink(mapID, mapName) then
				mapText = string.format("[[:%s]]", mapName)
			else
				mapText = mapName
			end
			local seen = patchData[ID] and Util:GetPatchVersion(patchData[ID]) or ""
			file:write(fs:format(ID, nameText, mapText, seen))
		end
	end
	file:write("|}\n")
	file:close()
end

main()
print("done")
