-- https://wow.gamepedia.com/ToyID
local KW = KethoWowpedia
local eb = KethoEditBox

-- C_ToyBox.GetToyInfo does not return names for these
-- and GetItemInfo does not return data
local noToyData = {
	[129045] = "Whitewater Tsunami",
	[130194] = "Silver Gilnean Brooch",
	[142360] = "Blazing Ember Signet",
	[163206] = "Weary Spirit Binding",
	[163565] = "Vulpera Scrapper's Armor",
	[163566] = "Vulpera Battle Banner",
	--[168836] = "???",
}

local expansion_icon = {
	"{{Wow-inline}}",
	"{{Bc-inline}}",
	"{{Wotlk-inline}}",
	"{{Cata-inline}}",
	"{{Mop-inline}}",
	"{{Wod-inline}}",
	"{{Legion-inline}}",
	"{{Bfa-inline}}",
	"{{Sl-inline}}",
}

-- /run KethoWowpedia:GetToyIDs(2e5)
function KW:GetToyIDs(num)
	eb:Show()
	local header = '{| class="sortable darktable zebra"\n! ID !! Item ID !! !! Name !! Source !! Patch'
	eb:InsertLine(header)
	local fs = '|-\n| align="center" | %d |||| [https://www.wowhead.com/item=%d %d] |||| %s |||| %s |||| %s |||| %s'

	local sources, expansions, uncategorized = self:GetToySources()
	local toys = {}
	local count, countNotValid = 0, 0
	for i = 1, num do
		local itemID, name = C_ToyBox.GetToyInfo(i)
		local notValid = (i>=72220 and i<=72233) -- 14 IDs not valid
		if itemID then
			if notValid then
				countNotValid = countNotValid + 1
			else
				count = count + 1
				local linkName = noToyData[itemID] or name
				local toyID, flags, sourceType = unpack(self.dbc.toy[itemID])
				local source = self.data.SourceTypeEnum[sourceType+1]
				local hidden = bit.band(flags, 0x2) > 0
				local sourceText
				if noToyData[itemID] then
					sourceText = "❌"
				elseif source and hidden then
					sourceText = format("(%s)", source)
				elseif source then
					sourceText = source
				elseif hidden then
					sourceText = "(Hidden)"
				end
				toys[toyID] = fs:format(
					toyID,
					itemID, itemID,
					expansion_icon[expansions[itemID]] or "",
					(linkName and format("[[:%s]]", linkName) or ""),
					sourceText or "",
					self.date.toy[toyID] or ""
				)
			end
		end
	end
	for _, k in pairs(self.util:ProxySort(toys)) do
		eb:InsertLine(toys[k])
	end
	print(count, countNotValid)
	eb:InsertLine("|}")
end

-- /spew KethoWowpedia:GetToySources()
function KW:GetToySources()
	local sources = {}
	local expansions = {}
	local uncategorized = {}
	C_ToyBox.SetUnusableShown(true) -- this otherwise messes with the filters

	-- sources
	-- if unchecking all sources there are still 4 pages of toys left
	C_ToyBox.SetAllSourceTypeFilters(false)
	for i = 1, C_ToyBox.GetNumFilteredToys() do
		uncategorized[C_ToyBox.GetToyFromIndex(i)] = i
	end

	-- filter ids 5, 6, 9, 10, 11 are skipped, but they are still controlling something apparently
	for i = 1, C_PetJournal.GetNumPetSources() do
		C_ToyBox.SetSourceTypeFilter(i, true)
		for j = 1, C_ToyBox.GetNumFilteredToys() do
			local itemid = C_ToyBox.GetToyFromIndex(j)
			sources[itemid] = i
		end
		C_ToyBox.SetSourceTypeFilter(i, false)
	end
	C_ToyBox.SetAllSourceTypeFilters(true)

	-- expanions
	C_ToyBox.SetAllExpansionTypeFilters(false)
	for i = 1, GetNumExpansions() do
		C_ToyBox.SetExpansionTypeFilter(i, true)
		for j = 1, C_ToyBox.GetNumFilteredToys() do
			local itemid = C_ToyBox.GetToyFromIndex(j)
			if not expansions[itemid] then
				expansions[itemid] = i
			else
				print(itemid, i, "already exists!")
			end
		end
		C_ToyBox.SetExpansionTypeFilter(i, false)
	end
	C_ToyBox.SetAllExpansionTypeFilters(true)
	return sources, expansions, uncategorized
end
