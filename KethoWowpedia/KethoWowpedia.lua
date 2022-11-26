KethoWowpedia = {
	Util = {},
	data = {},
	patch = {},
	dbc = {},
}
local w = KethoWowpedia

w.Util.PtrVersion = "?"

function w.Util:SortTable(tbl)
	local t = {}
	for k in pairs(tbl) do
		tinsert(t, k)
	end
	sort(t)
	return t
end

function w.Util:GetLinkName(link, name, maxLength)
	local length = #name
	if link then
		name = format("[[%s||%s]]", link, name)
	else
		name = format("[[:%s]]", name)
	end
	if length > maxLength then
		name = format("<small>%s</small>", name)
	end
	return name
end

w.data.SourceTypeEnum = {
	--[0] = "Unknown",
	[1] = BATTLE_PET_SOURCE_1, -- drop
	[2] = BATTLE_PET_SOURCE_2, -- quest
	[3] = BATTLE_PET_SOURCE_3, -- vendor
	[4] = BATTLE_PET_SOURCE_4, -- profession
	[5] = BATTLE_PET_SOURCE_5, -- pet battle
	[6] = BATTLE_PET_SOURCE_6, -- achievement
	[7] = BATTLE_PET_SOURCE_7, -- world event
	[8] = BATTLE_PET_SOURCE_8, -- promotion
	[9] = BATTLE_PET_SOURCE_9, -- tcg
	[10] = BATTLE_PET_SOURCE_10, -- shop
	[11] = BATTLE_PET_SOURCE_11, -- discovery
}

w.data.patchfix = {
	["4.3.4"] = "4.x",
	["7.3.0"] = "7.x",
}
