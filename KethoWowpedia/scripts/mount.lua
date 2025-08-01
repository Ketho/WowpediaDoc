-- https://wow.gamepedia.com/MountID
local eb = KethoEditBox

local MountType = {
	[230] = "[[File:ability_mount_ridinghorse.png|18px]]", -- Ground
	--[231] = "Turtle",
	--[241] = "Qiraji",
	--[242] = "Spectral",
	[248] = "[[File:ability_mount_goldengryphon.png|18px]]", -- Flying
	[254] = "[[File:inv_misc_fish_turtle_02.png|18px]]", -- Aquatic
	--[269] = "Water Strider", -- removed in 8.2.0
	--[284] = "Chauffeured",
}

local wpLink = {
	[32] = "Reins of the Bengal Tiger",
	[253] = "Reins of the Black Drake",
	[633] = "Fiendish Hellfire Core", -- Hellfire Infernal
	[1025] = "The Hivemind (mount)",
	[1507] = "Darkmaul (item)",
}

local wpName = {
	[32] = "Bengal Tiger",
	[43] = "Fluorescent Green Mechanostrider",
}

local unobtainable = {
	[32] = true, -- Bengal Tiger
}

local function IsValidName(s)
	if s:find("[%[%]]") then
		return false
	end
	return true
end

-- /run KethoWowpedia:GetMountIDs(3000)
function KethoWowpedia:GetMountIDs(num)
	eb:Show()
	eb:InsertLine('{| class="sortable darktable zebra col1-center col2-center col3-center"\n! ID !! !! !! Name !! Source !! [[CreatureDisplayID|Display ID]] !! Spell ID !! Patch')
	local fs = "|-\n| %d |||| %s |||| %s |||| %s |||| %s |||| %s |||| %s |||| %s"

	for id = 1, num do
		local name, spellID, _, _, _, sourceType, _, isFactionSpecific, faction, shouldHideOnChar = C_MountJournal.GetMountInfoByID(id)
		if name then
			-- displayID can sometimes be nil when there are multiple ids
			-- and the IDs returned by GetMountAllCreatureDisplayInfoByID() are in a seemingly random order
			local displayID, _, _, _, mTypeID = C_MountJournal.GetMountInfoExtraByID(id)
			local allDisplay = C_MountJournal.GetMountAllCreatureDisplayInfoByID(id)

			local factionIcon = faction == 0 and "{{Horde}}" or faction == 1 and "{{Alliance}}" or ""
			local nameText = name
			if IsValidName(name) then
				nameText = self.util:GetLinkName(wpLink[id], wpName[id] or name, 40)
			end
			-- EnumeratedString 105: 6: Exclude from Journal if not learned
			local flags = self.dbc.mount[id] or 0
			local sourceText
			if mTypeID == 242 then
				sourceText = "❌ Spectral"
			elseif unobtainable[id] then
				sourceText = "❌"
			else
				sourceText = bit.band(flags, 0x40) > 0 and "❓ " or ""
				sourceText = sourceText..(self.data.SourceTypeEnum[sourceType] or "")
			end
			local isMultiple
			if allDisplay and #allDisplay > 1 then
				isMultiple = true
				sort(allDisplay, function(a, b)
					return a.creatureDisplayID < b.creatureDisplayID
				end)
				displayID = allDisplay[1].creatureDisplayID
			end
			local displayLink
			if displayID then -- can be nil
				displayLink = format("[https://wow.tools/mv/?displayID=%d %d]", displayID, displayID)
				if isMultiple then
					displayLink = displayLink.." {{api|C_MountJournal.GetMountAllCreatureDisplayInfoByID#Values|+}}"
				end
			else
				displayLink = ""
			end
			local patch = self.patch.mount[id] or ""
			patch = self.data.patchfix[patch] or patch
			if patch == self.Util.PtrVersion then
				patch = patch.." [[File:PTR_client.png|16px|link=]]"
			end
			eb:InsertLine(fs:format(
				id,
				factionIcon,
				MountType[mTypeID] or mTypeID,
				nameText,
				sourceText,
				displayLink,
				format("[https://www.wowhead.com/spell=%d %d]", spellID, spellID),
				patch
			))
		end
	end
	eb:InsertLine("|}")
end
