-- https://wowpedia.fandom.com/wiki/DungeonEncounterID
local Util = require("Util/Util")
local parser = require("Util/wowtoolsparser")
local dbc_patch = require("Projects/DBC/DBC_patch")
local OUTPUT = "out/page/DungeonEncounterID.txt"

local wpLink = {
	[426] = "Landslide (mountain giant)",
	[451] = "Kirtonos the Herald (tactics)",
	[526] = "Keristrasza (tactics)",
	[527] = "Keristrasza (tactics)",
	[594] = "Gahz'rilla",
	[608] = "Illidari Council",
	[793] = "Hakkar (tactics)",
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
	[2395] = "Hakkar the Soulflayer (tactics)",
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
	[1918] = true, -- Timed Damage Dummy
	[2018] = true, -- Second Prisoner
	[2019] = true, -- First Prisoner
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

local function IsValidName(id, name)
	if noEncounter[id] then
		return false
	elseif name:find("[%[(]") then
		return false
	end
	return true
end

local function IsValidMapName(id, name)
	if noMap[id] then
		return false
	elseif name:find("Scenario") then
		return false
	end
	return true
end

local function main(options)
	options = Util:GetFlavorOptions(options)
	local map_csv = Util:ReadCSV("map", parser, options, function(tbl, ID, l)
		tbl[ID] = l.MapName_lang
	end)
	local patchData = dbc_patch:GetPatchData("dungeonencounter", options)

	print("writing to "..OUTPUT)
	local file = io.open(OUTPUT, "w")
	file:write('{| class="sortable darktable zebra col1-center"\n! ID !! Name !! Map !! [[InstanceID]] !! Patch\n')
	local fs = '|-\n| %d || %s || %s || %s || %s\n'
	Util:ReadCSV("dungeonencounter", parser, options, function(_, ID, l)
		local encounterName = l.Name_lang
		local nameText
		if wpLink[ID] then
			nameText = string.format("[[%s|%s]]", wpLink[ID], encounterName)
		elseif IsValidName(ID, encounterName) then
			nameText = string.format("[[:%s]]", encounterName)
		else
			nameText = encounterName
		end

		local mapID = tonumber(l.MapID)
		local mapName = map_csv[mapID] or ""
		local mapText
		if mapLink[ID] then
			mapText = string.format("[[%s|%s]]", mapLink[ID], mapName)
		elseif IsValidMapName(mapID, mapName) then
			mapText = string.format("[[:%s]]", mapName)
		else
			mapText = mapName
		end
		local patch = patchData[ID] and Util:GetPatchVersion(patchData[ID]) or ""
		patch = Util.patchfix[patch] or patch
		if patch == Util.PtrVersion then
			patch = patch.." {{Test-inline}}"
		end
		file:write(fs:format(ID, nameText, mapText, mapID, patch))
	end)
	file:write("|}\n")
	file:close()
end

main()
print("done")
