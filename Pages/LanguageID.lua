-- https://wowpedia.fandom.com/wiki/LanguageID
local Util = require("Util/Util")
local parser = require("Util/wowtoolsparser")
local dbc_patch = require("Projects/DBC/DBC_patch")
local OUTPUT = "out/page/LanguageID.txt"

local wpIcon = {
	[8] = "{{ClassIcon|Demon Hunter}}", -- Demonic
	[10] = "{{Alliance}}{{Horde}}", -- blood elf, void elf
	[42] = "{{Alliance}}{{Horde}}", -- 7.0.3 cross faction communication
	[178] = "[[File:ClassIcon priest.png|16px|link=Voidform]]", -- Shath'Yar
}

local allianceIcon = {
	[2] = true, -- Darnassian
	[6] = true, -- Dwarvish
	[7] = true, -- Common
	[13] = true, -- Gnomish
	[35] = true, -- Draenei
	[37] = true, -- Gnomish Binary
	[42] = true, -- Pandaren
}

local hordeIcon = {
	[1] = true, -- Orcish
	[3] = true, -- Taurahe
	[10] = true, -- Thalassian
	[14] = true, -- Zandali
	[33] = true, -- Forsaken
	[38] = true, -- Goblin Binary
	[40] = true, -- Goblin
	[181] = true, -- Shalassian
	[285] = true, -- Vulpera
}

local wpLink = {
	[1] = "Orcish (language)",
	[7] = "Common (language)",
	[9] = "Titan (language)",
	[13] = "Gnomish (language)",
	[33] = "Gutterspeak",
	[35] = "Draenei (language)",
	[36] = "Zombie (language)",
	[40] = "Goblin (language)",
	[42] = "Pandaren (language)",
	[43] = "Pandaren (language)",
	[44] = "Pandaren (language)",
	[168] = "Sprite (language)",
	[180] = "Moonkin Stone (PTR)",
	[285] = "Vulpera (language)",
}

local function main(options)
	options = Util:GetFlavorOptions(options)
	options.initial = false
	local patchData = dbc_patch:GetPatchData("languages", options)
	local fs = "|-\n| %d || %s || %s || %s\n"
	print("writing to "..OUTPUT)
	local file = io.open(OUTPUT, "w")
	file:write('{| class="sortable darktable zebra col1-center col2-center"\n! ID !! !! Name !! Patch\n')
	Util:ReadCSV("languages", parser, options, function(_, ID, l)
		local icon
		if wpIcon[ID] then
			icon = wpIcon[ID]
		else
			if allianceIcon[ID] then
				icon = "Alliance"
			elseif hordeIcon[ID] then
				icon = "Horde"
			end
			icon = icon and string.format("{{%s}}", icon) or ""
		end
		local name
		if wpLink[ID] then
			name = string.format("[[%s|%s]]", wpLink[ID], l.Name_lang)
		else
			name = string.format("[[%s]]", l.Name_lang)
		end
		local patch = patchData[ID] and Util:GetPatchVersion(patchData[ID]) or ""
		if patch == Util.PtrVersion then
			patch = patch.." {{Test-inline}}"
		end
		file:write(fs:format(ID, icon or "", name, patch))
	end)
	file:write("|}\n")
	file:close()
end

main() -- ["ptr", "mainline", "classic"]
print("done")
