-- https://wow.gamepedia.com/BattlePetSpeciesID
local eb = KethoEditBox

local wpPetIcon = {
	[1] = "Humanoid",
	[2] = "Dragonkin",
	[3] = "Flying",
	[4] = "Undead",
	[5] = "Critter",
	[6] = "Magic",
	[7] = "Elemental",
	[8] = "Beast",
	[9] = "Aquatic",
	[10] = "Mechanical",
}

local wpLink = {
	[495] = "Frog (critter)",
	[890] = "Spike (lizard)",
	[891] = "Ripper (tiger)",
	[894] = "Flutterby (moth)",
	[951] = "Goliath (pet)",
	[960] = "Gnasher (crocolisk)",
	[968] = "Mort (pet)",
	[969] = "Stitch (pet)",
	[1187] = "Gorespine (porcupine)",
	[1271] = "Chaos (NPC)",
	[1290] = "Rikki (otter)",
	[1805] = "Alarm-o-Bot (companion)",
	[1849] = "The Maw (Val'sharah)",
	[1972] = "Cosmos (pet)",
	[2062] = "Shadow (companion)",
	[2100] = "Gnasher (felstalker)",
	[2107] = "Watcher (guardian eye)",
	[2337] = "Bloodtusk (Nazmir)",
	[2347] = "Milo (spider)",
	[2401] = "Rooter (item)",
	[2407] = "Bloody Rabbit Fang",
	[2838] = "C'Thuffer (companion)",
	[2921] = "Gorm Harrier (companion)",
	[2986] = "Whirly (battle pet)",
	[3107] = "Gurgl (battle pet)",
}

local devPet = {
	[2] = true, -- Dumptruck; Unobtainable, Wild
	[462] = true, -- Jacob the Test Seagull; DBC Vendor, Unobtainable, Wild, Description
	[1257] = true, -- Crafty; DBC Drop, Unobtainable, Wild, Description
	[1410] = true, -- Mechanical Training Dummy; Unobtainable
	[2046] = true, -- Arne's Test Pet; DBC Drop, Unobtainable, Description
	[2076] = true, -- SpeedyNumberIII; Wild
	[2144] = true, -- REUSE; DBC Drop, Unobtainable
	[2480] = true, -- Test Pet; DBC Drop, Unobtainable, Description
	[2871] = true, -- Pet Training Dummy; Unobtainable, Wild
}

local unobtainablePet = {
	[344] = true, -- Green Balloon; DBC Vendor, Unobtainable
	[345] = true, -- Yellow Balloon; DBC Vendor, Unobtainable
	[1757] = true, -- Brown Piglet; DBC Pet Battle, Unobtainable, Wild
	[1758] = true, -- Black Piglet; DBC Pet Battle, Unobtainable, Wild
}

local function GetNumKeys(tbl)
	local v = 0
	for _ in pairs(tbl) do
		v = v + 1
	end
	return v
end

-- /run KethoWowpedia:GetPetSpeciesIDs(4e3)
function KethoWowpedia:GetPetSpeciesIDs(num)
	eb:Show()
	eb:InsertLine('{| class="sortable darktable zebra col1-center"\n! ID !! !! !! !! Name !! Source !! [[CreatureDisplayID|Display ID]] !! Spell ID !! NPC ID !! Patch')
	local fs = "|-\n| %d |||| %s |||| %s |||| %s |||| %s |||| %s |||| %s |||| %s |||| %s |||| %s"
	local sources, visible = self:GetPetSources()

	for id = 1, num do
		local name, _, petType, npcID, ttSource, ttDesc, isWild, canBattle, tradeable, _, obtainable, displayID = C_PetJournal.GetPetInfoBySpeciesID(id)
		if type(name) == "string" then
			local spellID, sourceType, flags = unpack(self.dbc.battlepetspecies[id])
			local linkName = self.Util:GetLinkName(wpLink[id], name, 32)
			local hideUntilLearned = bit.band(flags, 0x4000) > 0
			local sourceText = "😕"
			if sources[id] then
				sourceText = self.data.SourceTypeEnum[sources[id]]
				if hideUntilLearned then
					sourceText = "❓ "..sourceText
				end
			elseif visible[id] then
				sourceText = ""
			else
				local dbcSource = self.data.SourceTypeEnum[sourceType+1]
				local pred = { -- predicates
					dbcSource = dbcSource,
					desc = #ttDesc > 0 and true or nil, -- false counts as a key
					isWild = isWild and true or nil,
					unobtainable = not obtainable and true or nil,
				}
				local numPred = GetNumKeys(pred)
				if devPet[id] then
					sourceText = "[[File:ProfIcons_engineering.png|16px|link=]]"
				elseif unobtainablePet[id] then
					sourceText = "❌"
				elseif ((dbcSource and numPred == 3) or numPred == 2) and pred.unobtainable and pred.isWild then
					sourceText = "❌ Battle"
				elseif ((dbcSource and numPred == 2) or numPred == 1) and pred.unobtainable then
					sourceText = "❌ Tamer Battle"
				elseif dbcSource and numPred == 2 and pred.desc then
					sourceText = "❓ "..dbcSource
				elseif pred.unobtainable then
					sourceText = "❌"
				end
			end

			local displayLink = format("[https://wow.tools/mv/?displayID=%d %d]", displayID, displayID)
			local numDisplayIDs = C_PetJournal.GetNumDisplays(id)
			if numDisplayIDs and numDisplayIDs > 1 then
				displayLink = displayLink.." {{api|C_PetJournal.GetDisplayIDByIndex#Values|+}}"
			end
			local patch = self.patch.battlepetspecies[id] or ""
			if patch == self.Util.PtrVersion then
				patch = patch.." {{Test-inline}}"
			end
			eb:InsertLine(fs:format(
				id,
				canBattle and "{{Pet||Yes}}" or "",
				tradeable and obtainable and "{{Pet||Trade}}" or "",
				format("{{PetIcon||%s}}", wpPetIcon[petType]),
				linkName,
				sourceText,
				displayLink,
				spellID and spellID > 0 and format("[https://www.wowhead.com/spell=%d %d]", spellID, spellID) or "",
				format("[https://www.wowhead.com/npc=%d %d]", npcID, npcID),
				patch
			))
		end
	end
	eb:InsertLine("|}")
end

function KethoWowpedia:GetPetSources()
	local sources = {}
	C_PetJournal.SetAllPetSourcesChecked(false)
	for i = 1, C_PetJournal.GetNumPetSources() do
		C_PetJournal.SetPetSourceChecked(i, true)
		for j = 1, C_PetJournal.GetNumPets() do
			local _, speciesId = C_PetJournal.GetPetInfoByIndex(j)
			sources[speciesId] = i
		end
		C_PetJournal.SetPetSourceChecked(i, false)
	end
	C_PetJournal.SetAllPetSourcesChecked(true)
	-- some pets are not filtered by a specific source category
	-- but still get hidden when using "Uncheck All"
	local visible = {}
	for i = 1, C_PetJournal.GetNumPets() do
		local _, speciesID = C_PetJournal.GetPetInfoByIndex(i)
		visible[speciesID] = true
	end
	return sources, visible
end
