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
	local header = '{| class="sortable darktable zebra"\n! ID !! !! !! !! Name !! Source !! [[CreatureDisplayID|Display ID]] !! Spell ID !! NPC ID !! Patch'
	eb:InsertLine(header)
	local fs = "|-\n| align=\"center\" | %d |||| %s |||| %s |||| %s |||| %s |||| %s |||| %s |||| %s |||| [https://www.wowhead.com/npc=%d %d] |||| %s"
	local sources = self:GetPetSources()

	local count = 0
	for i = 1, num do
		local name, _, petType, companionID, tooltipSource, _, isWild, canBattle, isTradeable, _, obtainable, creatureDisplayID = C_PetJournal.GetPetInfoBySpeciesID(i)
		if type(name) == "string" then
			count = count + 1
			local model = self.dbc.creaturedisplayinfo[creatureDisplayID]
			local filemodel = self.dbc.creaturemodeldata[model]
			local displayLink = format("[https://wow.tools/mv/?filedataid=%d&type=m2 %d]", filemodel, creatureDisplayID)
			local spellID = self.dbc.battlepetspecies[i]
			local linkName = self.util:GetLinkName(wpLink[i], name, 32)

			eb:InsertLine(fs:format(i,
				canBattle and "{{Pet||Yes}}" or "",
				isTradeable and "{{Pet||Trade}}" or "",
				format("{{PetIcon||%s}}", wpPetIcon[petType]),
				linkName,
				self.data.SourceTypeEnum[sources[i]] or "❌",
				displayLink,
				spellID and spellID > 0 and format("[https://www.wowhead.com/spell=%d %d]", spellID, spellID) or "",
				companionID, companionID,
				self.patch.battlepetspecies[i] or ""
			))
		end
	end
	print(count)
	eb:InsertLine("|}")
end

function KethoWowpedia:GetPetSources()
	local t = {}
	C_PetJournal.SetAllPetSourcesChecked(false)
	for i = 1, C_PetJournal.GetNumPetSources() do
		C_PetJournal.SetPetSourceChecked(i, true)
		for j = 1, C_PetJournal.GetNumPets() do
			local _, speciesId = C_PetJournal.GetPetInfoByIndex(j)
			t[speciesId] = i
		end
		C_PetJournal.SetPetSourceChecked(i, false)
	end
	C_PetJournal.SetAllPetSourcesChecked(true)
	return t
end
