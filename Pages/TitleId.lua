-- https://wowpedia.fandom.com/wiki/TitleId
local parser = require("Util/wowtoolsparser")
local Util = require("Util/Util")
local dbc_patch = require("Projects/DBC/DBC_patch")
local OUTPUT = "out/page/TitleId.txt"

-- by mask id
local wplink = {
	[1] = "Private (Legacy)",
	[2] = "Corporal (Legacy)",
	[3] = "Sergeant (Alliance Legacy)",
	[4] = "Master Sergeant (Legacy)",
	[5] = "Sergeant Major (Legacy)",
	[6] = "Knight (Legacy)",
	[7] = "Knight-Lieutenant (Legacy)",
	[8] = "Knight-Captain (Legacy)",
	[9] = "Knight-Champion (Legacy)",
	[10] = "Lieutenant Commander (Legacy)",
	[11] = "Commander (Legacy)",
	[12] = "Marshal (Legacy)",
	[13] = "Field Marshal (Legacy)",
	[14] = "Grand Marshal (Legacy)",

	[17] = "Sergeant (Horde Legacy)",
	[15] = "Scout (Legacy)",
	[16] = "Grunt (Legacy)",
	[18] = "Senior Sergeant (Legacy)",
	[19] = "First Sergeant (Legacy)",
	[20] = "Stone Guard (Legacy)",
	[21] = "Blood Guard (Legacy)",
	[22] = "Legionnaire (Legacy)",
	[23] = "Centurion (Legacy)",
	[24] = "Champion (Legacy)",
	[25] = "Lieutenant General (Legacy)",
	[26] = "General (Legacy)",
	[27] = "Warlord (Legacy)",
	[28] = "High Warlord (Legacy)",

	[29] = "Gladiator (title)",
	[30] = "Duelist (title)",
	[41] = "Battlemaster (title)",
	[43] = "Elder (title)",
	[44] = "Flame Warden (title)",
	[45] = "Flame Keeper",
	[50] = "Arena Master (title)",
	[53] = "Crashin' Thrashin' Commander",
	[61] = "Archmage (title)",
	[62] = "Battlelord (title)",
	[96] = "Flawless Victor",
	[98] = "Ambassador (title)",
	[101] = "Brewmaster (title)",
	[123] = "Crusader (title)",
	[144] = "Warbringer (title)",

	[156] = "Sergeant (Alliance)",
	[159] = "Knight (achievement)",
	[165] = "Marshal (achievement)",
	[169] = "Grunt (achievement)",
	[170] = "Sergeant (Horde)",
	[173] = "Stone Guard (achievement)",
	[177] = "Champion (achievement)",

	[190] = "Firelord (title)",
	[195] = "Farmer (title)",
	[205] = "The Shado-Master",
	[220] = "Khan (achievement)",
	[221] = "Stormbreaker",
	[227] = "Trainer (title)",
	[236] = "The Manipulator (title)",
	[240] = "Crazy for Cats",
	[241] = "Challenge Master: Gate of the Setting Sun",
	[242] = "Challenge Master: Mogu%27shan Palace",
	[243] = "Challenge Master: Scarlet Halls",
	[244] = "Challenge Master: Scarlet Monastery",
	[245] = "Challenge Master: Scholomance",
	[246] = "Challenge Master: Shado-Pan Monastery",
	[247] = "Challenge Master: Siege of Niuzao Temple",
	[248] = "Challenge Master: Stormstout Brewery",
	[249] = "Challenge Master: Temple of the Jade Serpent",
	[252] = "Crazy for Cats",
	[262] = "The Manslayer (title)",
	[284] = "Steamwheedle Preservation Society (achievement)",
	[290] = "Challenge Warlord: Bronze",
	[291] = "Challenge Master: Bloodmaul Slag Mines",
	[292] = "Challenge Master: Iron Docks",
	[293] = "Challenge Master: Auchindoun",
	[294] = "Challenge Master: Skyreach",
	[295] = "Challenge Master: Shadowmoon Burial Grounds",
	[296] = "Challenge Master: Upper Blackrock Spire",
	[297] = "Challenge Master: Upper Blackrock Spire",
	[298] = "Challenge Master: The Everbloom",
	[299] = "Challenge Master: Grimrail Depot",
	[300] = "Savage Hero",
	[301] = "Mythic: Blackhand%27s Crucible",
	[304] = "Mythic: Imperator%27s Fall",
	[305] = "Artisan (title)",
	[317] = "Captain (title)",
	[319] = "Mythic: Archimonde",
	[320] = "Slayer (title)",
	[327] = "Archdruid (title)",
	[328] = "Deathlord (title)",
	[329] = "Grandmaster (title)",
	[333] = "No Stone Unturned",
	[334] = "Fabulous",
	[336] = "Farseer (title)",
	[338] = "Shadowblade (title)",
	[339] = "High Priest (title)",
	[341] = "Mythic: Xavius",
	[343] = "Lock, Stock and Two Smoking Goblins",
	[344] = "Illidari (title)",
	[345] = "Highlord (title)",
	[346] = "Ivory Talon",
	[354] = "The Unstoppable Force (title)",
	[356] = "Azeroth%27s Next Top Model",
	[358] = "Moonkin Monitoring",
	[362] = "Glory of the Tomb Raider",
	[365] = "Vixx%27s Chest of Tricks",
	[367] = "And We%27re All Out of Mana Buns",
	[371] = "Nigel Rifthold",
	[372] = "Priority Mail",
	[373] = "Prospector (title)",
	[375] = "The Horde Slayer (title)",
	[376] = "The Alliance Slayer (title)",
	[378] = "Inquisitor (title)",
	[381] = "Mythic: G%27huun",
	[383] = "Contender (title)",
}

local function GetNameText(v, maskID)
	local nameL, nameR = v:match("(.+) %%s (.+)")
	local namePrefix = v:match("(.+) %%s")
	local nameSuffix = v:match("%%s (.+)")
	local nameSuffixComma = v:match("%%s, (.+)")
	local titleName = namePrefix or nameSuffix or nameSuffixComma

	local base
	if wplink[maskID] then
		base = string.format("%s|%s", wplink[maskID], titleName)
	else
		base = string.format(":%s", titleName)
	end

	local nameText
	if nameL then -- 408: Pilgrim %s the Mallet Bearer
		nameText = string.format("[[%s %s|%s %%s %s]]", nameL, nameR, nameL, nameR)
	elseif namePrefix then
		nameText = string.format("[[%s]] %%s", base)
	elseif nameSuffix then
		nameText = string.format("%%s [[%s]]", base)
	elseif nameSuffixComma then
		nameText = string.format("%%s, [[%s]]", base)
	end
	return nameText
end

local header = '{| class="sortable darktable zebra col1-center col2-center"\n! Mask ID !! Title ID !! Name !! Patch\n'
local fs = '|-\n| %d || [https://www.wowhead.com/title=%d %d] || %s || %s\n'

local function main(options)
	options = Util:GetFlavorOptions(options)
	options.initial = false
	local dbc, build = parser:ReadCSV("chartitles", options)
	local patchData = dbc_patch:GetPatchData("chartitles", options)
	print("writing to "..OUTPUT)
	local file = io.open(OUTPUT, "w")

	file:write(header)
	for l in dbc:lines() do
		local ID = tonumber(l.ID)
		local maskID = tonumber(l.Mask_ID)
		if ID then
			local nameText
			if l.Name_lang ~= l.Name1_lang then
				local male = GetNameText(l.Name_lang, maskID)
				local female = GetNameText(l.Name1_lang, maskID)
				nameText = string.format("%s / %s", male, female)
			else
				nameText = GetNameText(l.Name_lang, maskID)
			end
			local patch = patchData[ID] and Util:GetPatchVersion(patchData[ID]) or ""
			patch = Util.patchfix[patch] or patch
			if patch == Util.PtrVersion then
				patch = patch.." {{Test-inline}}"
			end
			file:write(fs:format(maskID, ID, ID, nameText, patch))
		end
	end
	file:write("|}\n")
	file:close()
end

main("wrath") -- ["ptr", "mainline", "classic"]
print("done")
