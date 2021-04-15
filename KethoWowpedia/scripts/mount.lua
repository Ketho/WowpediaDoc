-- https://wow.gamepedia.com/MountID
local KW = KethoWowpedia
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
	[1025] = "The Hivemind (mount)",
}

local wpName = {
	[32] = "Bengal Tiger",
	[43] = "Fluorescent Green Mechanostrider",
}

-- /run KethoWowpedia:GetMountIDs(2000)
function KW:GetMountIDs(num)
	eb:Show()
	local header = '{| class="sortable darktable zebra"\n! ID !! !! !! Name !! Source !! [[CreatureDisplayID|Display ID]] !! Spell ID !! Patch'
	eb:InsertLine(header)
	local fs = "|-\n| align=\"center\" | %d |||| %s |||| %s |||| %s |||| %s |||| %s |||| [https://www.wowhead.com/spell=%d %d] |||| %s"

	local count = 0
	for i = 1, num do
		local name, spellID, _, _, _, sourceType, _, isFactionSpecific, faction, shouldHideOnChar = C_MountJournal.GetMountInfoByID(i)
		if name then
			count = count + 1
			local displayID, _, _, _, mTypeID = C_MountJournal.GetMountInfoExtraByID(i)
			local allDisplayIDs = C_MountJournal.GetMountAllCreatureDisplayInfoByID(i)
			local isMultipleDisplay
			if allDisplayIDs and #allDisplayIDs > 1 then
				isMultipleDisplay = true
				sort(allDisplayIDs, function(a, b)
					return a.creatureDisplayID < b.creatureDisplayID
				end)
				displayID = allDisplayIDs[1].creatureDisplayID
			end

			local model = self.dbc.creaturedisplayinfo[displayID]
			local filemodel = self.dbc.creaturemodeldata[model]
			local displayIDLink = format("[https://wow.tools/mv/?filedataid=%d&type=m2 %d]", filemodel, displayID)
			if isMultipleDisplay then
				displayIDLink = displayIDLink.." {{api|C_MountJournal.GetMountAllCreatureDisplayInfoByID#Values|+}}"
			end

			local factionIcon = faction == 0 and "{{Horde}}" or faction == 1 and "{{Alliance}}" or ""
			local linkName = self.util:GetLinkName(wpLink[i], wpName[i] or name, 40)
			-- EnumeratedString 105: 6: Exclude from Journal if not learned
			local flags = self.dbc.mount[i]
			local isHidden = bit.band(flags, 0x40) > 0 and "❌ " or ""
			eb:InsertLine(fs:format(i,
				factionIcon,
				MountType[mTypeID] or mTypeID,
				linkName,
				isHidden..(self.data.SourceTypeEnum[sourceType] or ""),
				displayIDLink,
				spellID, spellID,
				self.date.mount[i] or ""
			))
		end
	end
	print(count, #C_MountJournal.GetMountIDs())
	eb:InsertLine("|}")
end
