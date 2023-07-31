-- https://wow.gamepedia.com/ToyID
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
	[168836] = "", -- unknown
}

local wpExpansion = {
	[1] = "{{Wow-inline}}",
	[2] = "{{Bc-inline}}",
	[3] = "{{Wotlk-inline}}",
	[4] = "{{Cata-inline}}",
	[5] = "{{Mop-inline}}",
	[6] = "{{Wod-inline}}",
	[7] = "{{Legion-inline}}",
	[8] = "{{Bfa-inline}}",
	[9] = "{{Sl-inline}}",
	[10] = "{{Df-inline}}",
}

local wpLink = {
	[1255] = "Rubbery Fish Head (toy)",
}

-- remember look at each category beforehand to cache the items!
-- /run KethoWowpedia:GetToyIDs(3e5)
function KethoWowpedia:GetToyIDs(num)
	eb:Show()
	eb:InsertLine('{| class="sortable darktable zebra col1-center"\n! ID !! Item ID !! !! Name !! Source !! Patch')
	local fs = '|-\n| %d |||| %s |||| %s |||| %s |||| %s |||| %s'

	local sources, expansions, uncategorized = self:GetToySources()
	local lines = {}
	local item_pk = {} -- prefer to have it sorted by toyID in lua table
	for k, v in pairs(self.dbc.toy) do
		item_pk[v[1]] = {k, v[2], v[3]}
	end
	for id = 1, num do
		local itemID, name = C_ToyBox.GetToyInfo(id)
		local invalid = (id>=72220 and id<=72233) -- 14 IDs not valid
		if itemID and not invalid then
			local toyID, flags, sourceType = unpack(item_pk[itemID])
			local linkName = noToyData[itemID] or name
			if wpLink[toyID] then
				linkName = format("[[%s||%s]]", wpLink[toyID], linkName)
			elseif linkName and #linkName>0 then
				linkName = format("[[:%s]]", linkName)
			end
			local source = self.data.SourceTypeEnum[sourceType+1]
			local hidden = bit.band(flags, 0x2) > 0
			local sourceText = ""
			if noToyData[itemID] then
				sourceText = "❌"
			elseif source and hidden then
				sourceText = format("❓ %s", source)
			elseif source then
				sourceText = source
			elseif hidden then
				sourceText = "❓"
			end
			local patch = self.patch.toy[toyID] or ""
			patch = self.data.patchfix[patch] or patch
			if patch == self.Util.PtrVersion then
				patch = patch.." [[File:PTR_client.png|16px|link=]]"
			end
			lines[toyID] = fs:format(
				toyID,
				format("[https://www.wowhead.com/item=%d %d]", itemID, itemID),
				wpExpansion[expansions[itemID]] or "",
				linkName or "",
				sourceText,
				patch
			)
		end
	end
	for _, k in pairs(self.Util:SortTable(lines)) do
		eb:InsertLine(lines[k])
	end
	eb:InsertLine("|}")
end

function KethoWowpedia:GetToySources()
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
	-- expansions
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
