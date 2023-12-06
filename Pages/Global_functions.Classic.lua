-- https://wowpedia.fandom.com/wiki/Global_functions/Classic
-- https://wowpedia.fandom.com/wiki/Events/Classic
-- https://wowpedia.fandom.com/wiki/Console_variables/Classic
local Util = require("Util/Util")
local Path = require "path"

local m = {}

local sources = {
	api = {
		label = "API Name",
		url = "https://raw.githubusercontent.com/Ketho/BlizzardInterfaceResources/%s/Resources/GlobalAPI.lua",
		cache = "cache_lua/GlobalAPI_%s.lua",
		out = "out/page/CompareApi.txt",
		location = function(tbl)
			return tbl[1]
		end,
		map = function(tbl)
			return Util:ToMap(tbl)
		end,
		name_fs = "[[API %s|%s]]",
	},
	event = {
		label = "Event Name",
		url = "https://raw.githubusercontent.com/Ketho/BlizzardInterfaceResources/%s/Resources/Events.lua",
		cache = "cache_lua/Events_%s.lua",
		out = "out/page/CompareEvent.txt",
		location = function(tbl)
			return tbl
		end,
		map = function(tbl)
			local t = {}
			for _, system in pairs(tbl) do
				for _, event in pairs(system) do
					t[event] = true
				end
			end
			return t
		end,
		name_fs = "[[%s]]",
	},
	cvar = {
		label = "CVar Name",
		url = "https://raw.githubusercontent.com/Ketho/BlizzardInterfaceResources/%s/Resources/CVars.lua",
		cache = "cache_lua/CVars_%s.lua",
		out = "out/page/CompareCVars.txt",
		location = function(tbl)
			return tbl[1].var
		end,
		map = function(tbl)
			local t = {}
			for cvar, info in pairs(tbl) do
				t[cvar] = info
			end
			return t
		end,
		name_fs = "[[CVar %s|%s]]",
		header_fs = '! !! !! !! align="left" | %s !! Default !! Category !! Scope !! align="left" | Description\n',
		sectioncols = 8,
		sortFunc = function(a, b)
			return a:lower() < b:lower()
		end
	},
}

-- https://github.com/Ketho/BlizzardInterfaceResources/branches
local branches = {
	"mainline",
	"wrath",
	"vanilla",
}

-- avoid using templates as that increases page processing time
local wp_icons = {
	mainline = "[[File:Dragonflight-Icon-Inline.png|34px|link=]]",
	wrath = "[[File:Wrath-Logo-Small.png|link=]]",
	vanilla = "[[File:WoW Icon update.png|link=]]",
}

local sections = {
	{id = "vanilla", label = "Vanilla"},
	{id = "wrath", label = "Wrath"},
	{id = "both", label = "Wrath & Vanilla"},
	{id = "retail_vanilla", label = "Mainline & Vanilla"},
	{id = "retail_wrath", label = "Mainline & Wrath"},
	{id = "retail_both", label = "Mainline & Wrath & Vanilla"},
}

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

local function sortLowerCase(a, b)
	return a:lower() < b:lower()
end

function m:GetData(sourceType)
	local info = sources[sourceType]
	local parts = {}
	local mainTbl = {}
	local sectionData = {}
	for _, tbl in pairs(sections) do
		sectionData[tbl.id] = {}
	end

	for _, branch in pairs(branches) do
		local fileTbl = Util:DownloadAndRun(
			info.cache:format(branch),
			info.url:format(branch)
		)
		local location = info.location(fileTbl)
		parts[branch] = info.map(location)
		for name in pairs(parts[branch]) do
			mainTbl[name] = true
		end
	end

	for name in pairs(mainTbl) do
		local retail = parts.mainline[name]
		local wrath = parts.wrath[name]
		local vanilla = parts.vanilla[name]

		if retail then
			if wrath and vanilla then
				sectionData.retail_both[name] = wrath
			elseif wrath then
				sectionData.retail_wrath[name] = wrath
			elseif vanilla then
				sectionData.retail_vanilla[name] = vanilla
			end
		else
			if wrath and vanilla then
				sectionData.both[name] = wrath
			elseif wrath then
				sectionData.wrath[name] = wrath
			elseif vanilla then
				sectionData.vanilla[name] = vanilla
			end
		end
	end
	return parts, sectionData
end

function m:GetEventPayload()
	local branch = "mainline"
	local addons_path = Path.join(Util:GetLatestBuild(branch), "AddOns")
	require("WowDocLoader.WowDocLoader"):main(addons_path, branch)
	local t = {}
	for _, event in pairs(APIDocumentation.events) do
		if event.Payload then
			local payload = event:GetPayloadString(false, false)
			--print(event.LiteralName, payload)
			if #payload>160 and (event.LiteralName:find("^CHAT_MSG") or event.LiteralName:find("^CHAT_COMBAT_MSG")) then
				payload = "''CHAT_MSG''"
			end
			t[event.LiteralName] = payload
		end
	end
	return t
end

local function main()
	local eventDoc = m:GetEventPayload()
	for source, info in pairs(sources) do
		local parts, data = m:GetData(source)

		print("writing to", info.out)
		local file = io.open(info.out, "w")
		file:write('{| class="sortable darktable zebra"\n')
		if info.header_fs then
			file:write(info.header_fs:format(info.label))
		else
			file:write(string.format('! !! !! !! align="left" | %s\n', info.label))
		end

		local section_fs = string.format('|-\n! colspan="%d" style="text-align:left; padding-left: 9em;" | %%s\n', info.sectioncols or 4)
		local row_fs = "|-\n| "..string.rep("%s", 4, " || ")

		for _, sectionInfo in pairs(sections) do
			if next(data[sectionInfo.id]) then
				file:write(section_fs:format(sectionInfo.label))
				for _, name in pairs(Util:SortTable(data[sectionInfo.id], info.sortFunc)) do
					local retail = parts.mainline[name] and wp_icons.mainline or ""
					local wrath = parts.wrath[name] and wp_icons.wrath or ""
					local vanilla = parts.vanilla[name] and wp_icons.vanilla or ""
					local nameLink = info.name_fs:format(name, name)
					file:write(row_fs:format(retail, wrath, vanilla, nameLink))
					if source == "event" and eventDoc[name] then
						file:write(string.format("<small>: %s</small>", eventDoc[name]))
					elseif source == "cvar" then
						local cvarInfo = parts.wrath[name] or parts.vanilla[name]
						local default, category, account, character, description = table.unpack(cvarInfo)
						local categoryName = cvar_enum[category] or ""
						local scope = account and "Account" or character and "Character" or ""
						file:write(string.format(" || %s || %s || %s || %s", default, categoryName, scope, description))
					end
					file:write("\n")
				end
			end
		end
		file:write("|}\n")
		file:close()
	end
end

main()
print("done")
