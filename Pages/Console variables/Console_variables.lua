-- https://wow.gamepedia.com/Console_variables/Complete_list
local Path = require "path"
local Util = require("Util.Util")

BRANCH = "mainline"
OUTPUT_CVAR = "out/page/Console_variables_cvar.txt"
OUTPUT_COMMAND = "out/page/Console_variables_command.txt"
local m = {}

function m:main()
	local base_folder = Path.join("Pages", "Console variables")
	local blizzres_cvars = require(Path.join(base_folder, "blizzres"))()
	local framexml_strings = require(Path.join(base_folder, "framexml"))(blizzres_cvars)
	local binary_strings = require(Path.join(base_folder, "binaries"))(blizzres_cvars)
	self:WriteCVarList(blizzres_cvars[1].var, framexml_strings, binary_strings)
	self:WriteCommandList(blizzres_cvars[1].command)
end

local cvar_enum = {
	[0] = "Debug",
	[1] = "Graphics",
	[2] = "Console",
	[3] = "Combat",
	[4] = "Game",
	[5] = "", -- "Default",
	[6] = "Net",
	[7] = "Sound",
	[8] = "Gm",
	[9] = "Reveal",
	[10] = "None",
}

function m:WriteCVarList(blizzres_cvars, framexml_strings, binary_strings)
	print("writing to "..OUTPUT_CVAR)
	local file = io.open(OUTPUT_CVAR, "w")

	file:write('{| class="sortable darktable zebra col2-center"\n')
	file:write("! !! !! Name !! Default !! Category !! Scope !! Description\n")
	local githubLink = "[[File:GitHub_Octocat.png|16px|link=https://github.com/Gethe/wow-ui-source/search?q=%s]]"
	local fs = "|-\n| %s || %s || %s\n| %s || %s || %s\n| %s\n"
	for _, cvar in pairs(Util:SortTable(blizzres_cvars, Util.SortNocase)) do
		local v = blizzres_cvars[cvar]
		local default, category, server, character, desc = table.unpack(v)
		local name = string.format("[[CVar %s|%s]]", cvar, cvar)
		file:write(fs:format(
			binary_strings[cvar] or "",
			framexml_strings[cvar] and githubLink:format(cvar) or "",
			name,
			default or "",
			cvar_enum[category],
			server and "Account" or character and "Character" or "",
			desc or ""
		))
	end
	file:close()
end

function m:WriteCommandList(blizzres_commands)
	print("writing to "..OUTPUT_COMMAND)
	local file = io.open(OUTPUT_COMMAND, "w")

	file:write('{| class="sortable darktable zebra col2-center"\n')
	file:write("! Name !! Category !! Description\n")
	local fs = "|-\n| %s\n| %s\n| %s\n"
	for _, command in pairs(Util:SortTable(blizzres_commands, Util.SortNocase)) do
		local v = blizzres_commands[command]
		local category, desc = table.unpack(v)
		local name = string.format("[[CVar %s|%s]]", command, command)
		file:write(fs:format(
			name,
			cvar_enum[category],
			desc or ""
		))
	end
	file:close()
end

m:main()
print("done")
