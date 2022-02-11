-- https://wowpedia.fandom.com/wiki/GarrFollowerID
local Util = require "Util/Util"
local parser = require "Util/wowtoolsparser"
local dbc_patch = require("Projects/DBC/DBC_patch")
local OUTPUT = "out/page/GarrFollowerID.txt"

local Enum_GarrisonFollowerType = {
	[1] = "{{Wod-inline}}", -- FollowerType_6_0
	[2] = "[[File:Inv_garrison_cargoship.png|18px]]", -- FollowerType_6_2
	[4] = "{{Legion-inline}}", -- FollowerType_7_0
	[22] = "{{Bfa-inline}}", -- FollowerType_8_0
	[123] = "{{Sl-inline}}", -- FollowerType_9_0
}

local Enum_Quality = {
	[1] = '<span class="qc-common">Common</span>',
	[2] = '<span class="qc-uncommon">Uncommon</span>',
	[3] = '<span class="qc-rare">Rare</span>',
	[4] = '<span class="qc-epic">Epic</span>',
	[5] = '<span class="qc-legendary">Legendary</span>',
}

local wplink = {
	[503] = "Master's Call (carrier)",
}

local function FormatLink(ID, s)
	if wplink[ID] then
		return string.format("[[%s|%s]]", wplink[ID], s)
	else
		return string.format("[[:%s]]", s)
	end
end

local function main(options)
	options = Util:GetFlavorOptions(options)
	options.initial = false
	local faction = parser:ReadCSV("garrfollower", options)
	local patchData = dbc_patch:GetPatchData("garrfollower", options)

	local creature_dbc = parser:ReadCSV("creature", options)
	local creatures = {}
	for l in creature_dbc:lines() do
		local ID = tonumber(l.ID)
		if ID then
			local name = l.Name_lang
			creatures[ID] = name
		end
	end

	print("writing "..OUTPUT)
	local file = io.open(OUTPUT, "w")
	file:write('{| class="sortable darktable zebra col1-center col2-center"\n')
	file:write("! ID !! !! {{Alliance}} Alliance !! {{Horde}} Horde !! Quality !! Patch")
	local fs_same	   = '\n|-\n| %d || %s || colspan="2" | %s || %s || %s'
	local fs_different = "\n|-\n| %d || %s || %s || %s || %s || %s"

	for l in faction:lines() do
		local ID = tonumber(l.ID)
		if ID then
			local name = l.Name_lang
			local garrfollowertype = tonumber(l.GarrFollowerTypeID)
			local allianceid = tonumber(l.AllianceCreatureID)
			local hordeid = tonumber(l.HordeCreatureID)
			local quality = tonumber(l.Quality)
			local flags = tonumber(l.Flags)

			if flags&0x4 == 0 then -- Internal Only
				local qualityText = Enum_Quality[quality]
				local followerTypeIcon = Enum_GarrisonFollowerType[garrfollowertype] or ""
				local allianceName = creatures[allianceid]
				local hordeName = creatures[hordeid]

				local patch = patchData[ID] and Util:GetPatchVersion(patchData[ID]) or ""
				if patch == Util.PtrVersion then
					patch = patch.." {{Test-inline}}"
				end
				if allianceName == hordeName then -- creature ID can be different but still have the same name
					file:write(fs_same:format(ID, followerTypeIcon, FormatLink(ID, allianceName), qualityText, patch))
				else
					file:write(fs_different:format(ID, followerTypeIcon, FormatLink(ID, allianceName), FormatLink(ID, hordeName), qualityText, patch))
				end
			end
		end
	end
	file:write("\n|}\n")
	file:close()
end

main() -- ["ptr", "mainline", "classic"]
print("done")