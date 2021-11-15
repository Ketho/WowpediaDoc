-- similar codebase as https://wowpedia.fandom.com/wiki/Module:API_info/cvar
local Util = require("Util/Util")
local data = Util:DownloadAndRun(
	"cache/CVars_mainline.lua",
	"https://raw.githubusercontent.com/Ketho/BlizzardInterfaceResources/mainline/Resources/CVars.lua"
)

local m = {}

local ConsoleCategory = {
	[0] = "Debug",
	[1] = "Graphics",
	[2] = "Console",
	[3] = "Combat",
	[4] = "Game",
	[5] = "Default",
	[6] = "Net",
	[7] = "Sound",
	[8] = "Gm",
	[9] = "Reveal",
	[10] = "None",
}

local fs = '<span class="tttemplatelink">%s</span><span style="display:none">%s</span>'

local function ColorText(text)
	return string.format('<span class="apitype">%s</span>', text)
end

local function GetCVarInfo(name)
	local cvar = data[1].var[name]
	if cvar then
		local t = {}
		-- cannot use unpack()
		local default, category, account, character, help = cvar[1], cvar[2], cvar[3], cvar[4], cvar[5]
		if #default > 0 then
			table.insert(t, "Default: <code>"..ColorText(default).."</code>")
		end
		-- if category ~= 5 then -- Default
		-- 	table.insert(t, "Category: "..ColorText(ConsoleCategory[category]))
		-- end
		if account or character then
			table.insert(t, "Scope: "..ColorText(account and "Account" or character and "Character"))
		end
		local text = table.concat(t, ", ")
		if #help > 0 then
			text = text.."<br><small>"..help.."</small>"
		end
		return text
	end
end

function m.GetTooltip(name, link)
	local info = GetCVarInfo(name)
	if info then
		return fs:format(link, info)
	end
end

return m
