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
	[1271] = "Chaos (NPC)",
	[1290] = "Rikki (otter)",
	[1805] = "Alarm-o-Bot (companion)",
	[1849] = "The Maw (Val'sharah)",
	[1972] = "Cosmos (pet)",
	[2062] = "Shadow (companion)",
	[2100] = "Gnasher (felstalker)",
	[2337] = "Bloodtusk (Nazmir)",
	[2347] = "Milo (spider)",
	[2401] = "Rooter (item)",
	[2407] = "Bloody Rabbit Fang",
	[2838] = "C'Thuffer (companion)",
	[2921] = "Gorm Harrier (companion)",
}

-- /run KethoWowpedia:GetPetSpeciesIDs(3500)
function KethoWowpedia:GetPetSpeciesIDs(num)
	eb:Show()
	eb:InsertLine('{| class="sortable darktable zebra"\n! ID !! !! !! !! Name !! Source !! [[CreatureDisplayID|Display ID]] !! Spell ID !! NPC ID !! Patch')
	local fs = "|-\n| align=\"center\" | %d |||| %s |||| %s |||| %s |||| %s |||| %s |||| %s |||| %s |||| %s |||| %s"
	local sources, visible = self:GetPetSources()

	for id = 1, num do
		local name, _, petType, npcID, ttSource, ttDesc, isWild, canBattle, isTradeable, _, obtainable, creatureDisplayID = C_PetJournal.GetPetInfoBySpeciesID(id)
		if type(name) == "string" then
			local spellID, sourceType = unpack(self.dbc.battlepetspecies[id])
			local isObtainable = #ttDesc > 0 -- difficult to ascertain whether a pet is actually obtainable
			local linkName = self.util:GetLinkName(wpLink[id], name, 32)

			local sourceText
			if sources[id] then
				sourceText = self.data.SourceTypeEnum[sources[id]]
			elseif visible[id] then
				sourceText = ""
			else
				sourceText = "❓"
				local dbcSource = self.data.SourceTypeEnum[sourceType]
				if dbcSource then
					sourceText = sourceText.." "..dbcSource
				end
			end

			local model = self.dbc.creaturedisplayinfo[creatureDisplayID]
			local filemodel = self.dbc.creaturemodeldata[model]
			local displayLink = format("[https://wow.tools/mv/?filedataid=%d&type=m2 %d]", filemodel, creatureDisplayID)
			local numDisplayIDs = C_PetJournal.GetNumDisplays(id)
			if numDisplayIDs and numDisplayIDs > 1 then
				displayLink = displayLink.." {{api|C_PetJournal.GetDisplayIDByIndex#Values|+}}"
			end

			eb:InsertLine(fs:format(
				id,
				canBattle and "{{Pet||Yes}}" or "",
				isObtainable and isTradeable and "{{Pet||Trade}}" or "",
				format("{{PetIcon||%s}}", wpPetIcon[petType]),
				linkName,
				isObtainable and sourceText or "❌",
				displayLink,
				spellID and spellID > 0 and format("[https://www.wowhead.com/spell=%d %d]", spellID, spellID) or "",
				format("[https://www.wowhead.com/npc=%d %d]", npcID, npcID),
				self.patch.battlepetspecies[id] or ""
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
