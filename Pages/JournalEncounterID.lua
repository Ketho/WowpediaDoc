-- https://wowpedia.fandom.com/wiki/JournalEncounterID
local util = require("util")
local parser = require("util.wago")
local dbc_patch = require("Projects/DBC/DBC_patch")
local OUTPUT = "out/page/JournalEncounterID.txt"

local wpLink = {
	[102] = "Commander Ulthok",
	[127] = "Isiset",
	[128] = "Ammunae",
	[129] = "Setesh",
	[130] = "Rajh",
	[134] = "Erudax",
	[154] = "Conclave of Wind",
	[157] = "Valiona and Theralion",
	[177] = "Gri'lek",
	[178] = "Hazza'rah",
	[179] = "Renataki",
	[180] = "Wushoolay",
	[196] = "Baleroc",
	[339] = "Alizabal",
	[429] = "Landslide (mountain giant)",
	[609] = "Krick and Ick",
	[814] = "Nalak",
	[1549] = "Twin Emperors",
	[1589] = "Illidari Council",
	[1594] = "Eredar Twins",
	[1618] = "Northrend Beasts",
	[1620] = "Faction Champions",
	[1621] = "Faction Champions",
}

local wpLinkDouble = {
	[487] = "[[Nekrum Gutchewer|Nekrum]] & [[Shadowpriest Sezz'ziz|Sezz'ziz]]",
	[639] = "[[:Skarvald]] & [[:Dalronn]]",
}

local noLink = {
	[2051] = true, -- PvP Battlegrounds
	[2438] = true, -- Generic Template
}

local patch_override = {
	["4.3.4"] = "",
	["7.3.0"] = "6.x / 7.x",
}

local function main(options)
	options = util:GetFlavorOptions(options)
	local journalinstance_csv = util:ReadCSV("journalinstance", parser, options, function(tbl, ID, l)
		tbl[ID] = l.Name_lang
	end)
	local journalencountercreature_csv = util:ReadCSV("journalencountercreature", parser, options, function(tbl, _, l)
		local encounterID = tonumber(l.JournalEncounterID)
		local displayID = tonumber(l.CreatureDisplayInfoID)
		local order = tonumber(l.OrderIndex)
		if order == 0 then
			tbl[encounterID] = displayID
		end
	end)
	local dungeonencounter_csv = util:ReadCSV("dungeonencounter", parser, options, function(tbl, ID, l)
		tbl[ID] = {l.Name_lang, tonumber(l.MapID)}
	end)
	local map_csv = util:ReadCSV("map", parser, options, function(tbl, ID, l)
		tbl[ID] = l.MapName_lang
	end)
	local patchData = dbc_patch:GetPatchData("journalencounter", options)

	local file = io.open(OUTPUT, "w")
	file:write('{| class="sortable darktable zebra col1-center"\n! ID !! Name !! Map !! [[DisplayID]] !! <small>[[DungeonEncounterID]]</small> !! [[InstanceID]] !! Patch\n')
	local fs = '|-\n| %d || %s || %s || %s || %s || %s || %s\n'
	util:ReadCSV("journalencounter", parser, options, function(_, ID, l)
		local name = l.Name_lang
		local journalInstanceID = tonumber(l.JournalInstanceID)
		local dungeonEncounterID = tonumber(l.DungeonEncounterID)
		local uimapID = tonumber(l.UiMapID)

		local nameText
		if wpLink[ID] then
			nameText = string.format("[[%s|%s]]", wpLink[ID], name)
		elseif wpLinkDouble[ID] then
			nameText = wpLinkDouble[ID]
		elseif noLink[ID] then
			nameText = name
		else
			nameText = string.format("[[:%s]]", name)
		end

		local displayID = journalencountercreature_csv[ID]
		local dungeonEncounterName, instanceID
		if dungeonEncounterID > 0 then
			dungeonEncounterName, instanceID = table.unpack(dungeonencounter_csv[dungeonEncounterID])
		end
		local patch = util:GetPatchText(patchData, ID, patch_override)

		file:write(fs:format(
			ID,
			nameText,
			journalInstanceID > 0 and string.format("[[%s]]", journalinstance_csv[journalInstanceID]) or "",
			displayID and string.format("[https://wow.tools/mv/?displayID=%d %d]", displayID, displayID) or "",
			dungeonEncounterID > 0 and string.format('<span title="%s">%d</span>', dungeonEncounterName, dungeonEncounterID) or "",
			dungeonEncounterID > 0 and string.format('<span title="%s">%d</span>', map_csv[instanceID], instanceID) or "",
			patch
		))
	end)
	file:write("|}\n")
	file:close()
	print("written "..OUTPUT)
end

main()
print("done")
