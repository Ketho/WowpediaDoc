-- https://wowpedia.fandom.com/wiki/LfgDungeonID
local util = require("util")
local parser = require("util.wago")
local dbc_patch = require("Projects/DBC/DBC_patch")
local OUTPUT = "out/page/LfgDungeonID.txt"

local wpLink = {
	[26] = "Foulspore Cavern",
	[30] = "Detention Block",
	[34] = "Warpwood Quarter",
	[36] = "Capital Gardens",
	[38] = "Dire Maul#Gordok Commons .2842-52.29",
	[40] = "Stratholme Main Gate",
	[195] = "Battle for Mount Hyjal (instance)",
	[220] = "Violet Hold (instance)",
	[221] = "Violet Hold (instance)",
	[272] = "Wicked Grotto",
	[273] = "Earth Song Falls",
	[274] = "Stratholme Service Entrance",
	[276] = "Blackrock Depths#Upper City",
	[286] = "Ahune",
	[288] = "Crown Chemical Company",
	[358] = "Rated battlegrounds",
	[416] = "Dragon Soul#Encounters",
	[604] = "The Assault on Zeb%27tula",
	[617] = "The Assault on Shaol%27mara",
	[640] = "Proving Grounds",
	[1966] = "Brawl: Comp Stomp",
	[1982] = "Battle for Stromgarde",
	[2007] = "Battle for Stromgarde",
}

local lfgType = {
	[1] = "dungeon",
	[2] = "raid",
	[4] = "outdoor",
	[6] = "random dungeon",
}

-- seems to differ from GetLFGDungeonInfo() subtype
local lfgSubtype = {
	[1] = "Dungeon",	-- 1 LFG_SUBTYPEID_DUNGEON
	-- [2] = "Heroic",	-- 2 LFG_SUBTYPEID_HEROIC
	[2] = "Raid",		-- 3 LFG_SUBTYPEID_RAID
	[3] = "Scenario",	-- 4 LFG_SUBTYPEID_SCENARIO
	[4] = "Flex Raid",	-- 5 LFG_SUBTYPEID_FLEXRAID
	[5] = "World PVP",	-- 6 LFG_SUBTYPEID_WORLDPVP
	[6] = "PVP Brawl",	-- 7 Arathi Basin Comp Stomp; Shado-Pan Showdown
}

local instanceTypes = {
	[1] = "party",
	[2] = "raid",
	[3] = "pvp",
	[5] = "scenario",
}

-- doublecheck with GetLFGDungeonInfo() once in a while
local timewalkingCT = { -- ContentTuning IDs
	[424] = true, -- Memories of Azeroth
	[617] = true,
	[1286] = true, -- Burning Crusade
	[1287] = true, -- Cataclysm
	[1288] = true, -- Wrath of the Lich King
	[1289] = true, -- Mists of Pandaria
	[1290] = true, -- Warlords of Draenor
	[2173] = true, -- Legion
}

local function IsValidName(s)
	if s:find("[%[%(%.]") then
		return false
	elseif s:find(" %- ") then
		return false
	elseif s:find("Random") then
		return false
	elseif s:find("Scenario") then
		return false
	elseif s:find("zzOLD") then
		return false
	elseif s:find("Test") then
		return false
	end
	return true
end

local patch_override = {
	["1.9.0"] = "",
	["2.4.3"] = "2.x",
	["4.3.4"] = "4.x",
	["7.3.0"] = "6.x / 7.x",
}

local function main(options)
	options = util:GetFlavorOptions(options)
	options.initial = false
	local difficulty_csv = util:ReadCSV("difficulty", parser, options, function(tbl, ID, l)
		local name = l.Name_lang
		local instanceType = tonumber(l.InstanceType)
		tbl[ID] = {instanceTypes[instanceType], name}
	end)
	local map_csv = util:ReadCSV("map", parser, options, function(tbl, ID, l)
		tbl[ID] = l.MapName_lang
	end)
	local patchData = dbc_patch:GetPatchData("lfgdungeons", options)

	local file = io.open(OUTPUT, "w")
	file:write('{| class="sortable darktable zebra col1-center"\n! ID !! Name !! Type !! [[DifficultyID]] !! [[InstanceID]] !! Patch\n')
	local fs = '|-\n| %d || %s || %s || %s || %s || %s\n'
	util:ReadCSV("lfgdungeons", parser, options, function(_, ID, l)
		local name = l.Name_lang
		local typeid = tonumber(l.TypeID)
		local subtype = tonumber(l.Subtype)
		local difficultyID = tonumber(l.DifficultyID)
		local instanceID = tonumber(l.MapID)
		local ctid = tonumber(l.ContentTuningID)

		local nameText
		if wpLink[ID] then
			nameText = string.format("[[%s|%s]]", wpLink[ID], name)
		elseif IsValidName(name) then
			nameText = string.format("[[:%s]]", name)
		else
			nameText = name
		end

		local typeText
		local diffText, diffName
		if typeid == 4 then -- outdoor
			typeText = lfgType[typeid]
		elseif difficultyID == 0 then
			typeText = lfgSubtype[subtype] or ""
		else
			typeText, diffName = table.unpack(difficulty_csv[difficultyID])
			diffText = string.format('<span title="ID %d">%s</span>', difficultyID, diffName)
			if timewalkingCT[ctid] then
				diffText = "timewalking, "..diffText
			end
		end

		local mapText = ""
		if instanceID > -1 then
			mapText = string.format('<span title="%s">%d</span>', map_csv[instanceID] or "", instanceID)
		end
		local patch = util:GetPatchText(patchData, ID, patch_override)
		file:write(fs:format(ID, nameText, typeText, diffText or "", mapText, patch))
	end)
	file:write("|}\n")
	file:close()
	print("written "..OUTPUT)
end

main()
print("done")
