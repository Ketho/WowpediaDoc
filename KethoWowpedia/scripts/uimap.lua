-- https://wow.gamepedia.com/UiMapID
local eb = KethoEditBox

local MapType = {
	[0] = "Cosmic",
	[1] = "World",
	[2] = "Continent",
	[3] = "Zone",
	[4] = "Dungeon",
	[5] = "Micro",
	[6] = "Orphan",
}

local wpLinkMap = {
	[306] = "Scholomance (Classic)", -- ScholomanceOLD
	[307] = "Scholomance (Classic)", -- ScholomanceOLD
	[308] = "Scholomance (Classic)", -- ScholomanceOLD
	[309] = "Scholomance (Classic)", -- ScholomanceOLD
	[329] = "Hyjal Summit (Caverns of Time)", -- Hyjal Summit
	[589] = "Ashran Excavation", -- Ashran Mine
	[623] = "Southshore vs Tarren Mill", -- Hillsbrad Foothills (Southshore vs. Tarren Mill)
	[1045] = "Thros, the Blighted Lands", -- Thros, The Blighted Lands
	[1176] = "Breath of Pa%27ku", -- Breath Of Pa'ku
	[1177] = "Breath of Pa%27ku", -- Breath Of Pa'ku
	[1361] = "Old Ironforge", -- OldIronforge
	[1371] = "Gnomeregan", -- GnomereganA
	[1372] = "Gnomeregan", -- GnomereganB
	[1374] = "Gnomeregan", -- GnomereganD
	[1380] = "Gnomeregan", -- GnomereganC
}

local wpLinkFloor = {
	[148] = "Antechamber", -- The Antechamber of Ulduar
	[221] = "Pool of Ask'ar", -- The Pool of Ask'Ar
	[296] = "Twilight Caverns", -- The Twilight Caverns
	[453] = "Crimson Assembly Hall", -- The Crimson Assembly Hall
	[454] = "Vault of Kings Past", -- Vaults of Kings Past
	[856] = "Twisting Nether (Tomb of Sargeras)", -- The Twisting Nether
	[1544] = "Crimson Assembly Hall", -- The Crimson Assembly Hall
	[1545] = "Vault of Kings Past", -- Vaults of Kings Past
	-- also used as a whitelist
	[819] = "Library Floor", -- Library Floor
}

local patternsMap = {
	" %- ",
	"_",
	"%[",
	"%d",
}

local patternsFloor = {
	"er cave",
	"deck",
	"floor",
}

for _, v in pairs(patternsMap) do
	tinsert(patternsFloor, v)
end

local function IsValidName(s, patterns)
	s = s:lower()
	for _, p in pairs(patterns) do
		if s:find(p) then
			return false
		end
	end
	return true
end

-- /run KethoWowpedia:GetUiMapIDs(3000, 1000)
function KethoWowpedia:GetUiMapIDs(numMap, numGroup)
	eb:Show()
	eb:InsertLine('{| class="sortable darktable zebra col1-center"\n! ID !! Map Name !! Map Type !! Parent Map !! wago.tools !! Patch')
	local fs = '|-\n| %d |||| %s |||| %s |||| %s |||| %s |||| %s'
	local mapFloors = {}
	for i = 1, numGroup do
		local members = C_Map.GetMapGroupMembersInfo(i)
		if members then
			for _, info in pairs(members) do
				mapFloors[info.mapID] = info.name
			end
		end
	end
	local mapInfo = {}
	for i = 1, numMap do
		local info = C_Map.GetMapInfo(i)
		if info then
			mapInfo[i] = info
		end
	end
	for _, id in pairs(self.util:SortTable(mapInfo)) do
		local info = mapInfo[id]
		local mapText = info.name
		if wpLinkMap[id] then
			mapText = format("[[%s|%s]]", wpLinkMap[id], mapText)
		elseif #mapText > 0 and IsValidName(mapText, patternsMap) then
			mapText = format("[[:%s]]", mapText)
		end

		local floorText = mapFloors[info.mapID]
		if floorText then
			if wpLinkFloor[id] then
				floorText = format("[[%s|%s]]", wpLinkFloor[id], floorText)
			elseif IsValidName(floorText, patternsFloor) then
				floorText = format("[[:%s]]", floorText)
			end
			mapText = mapText.." - "..floorText
		end

		local parentID = info.parentMapID
		local parentMap = ""
		if parentID > 0 then
			parentMap = format('<span title="ID %d">%s</span>', mapInfo[parentID].mapID, mapInfo[parentID].name)
		end
		local patch = self.patch.uimap[id] or ""
		if patch == self.Util.PtrVersion then
			patch = patch.." [[File:PTR_client.png|16px|link=]]"
		end
		eb:InsertLine(fs:format(
			info.mapID,
			mapText,
			MapType[info.mapType],
			parentMap,
			format("[https://wago.tools/maps/worldmap/%d view]", id),
			patch
		))
	end
	eb:InsertLine("|}")
end
