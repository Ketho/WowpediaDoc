-- https://wowpedia.fandom.com/wiki/Global_functions/Classic
-- https://wowpedia.fandom.com/wiki/Events/Classic
-- https://wowpedia.fandom.com/wiki/Console_variables/Classic
local Util = require("Util/Util")

local m = {}

local sources = {
	api = {
		label = "API Name",
		url = "https://raw.githubusercontent.com/Ketho/BlizzardInterfaceResources/%s/Resources/GlobalAPI.lua",
		cache = "cache/GlobalAPI_%s.lua",
		out = "out/lua/CompareApi.txt",
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
		cache = "cache/Events_%s.lua",
		out = "out/lua/CompareEvent.txt",
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
		cache = "cache/CVars_%s.lua",
		out = "out/lua/CompareCVars.txt",
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
	"live",
	"vanilla",
	"tbc",
}

-- avoid using templates as that increases page processing time
local wp_icons = {
	live = "[[File:Shadowlands-Logo-Small.png|34px|link=]]",
	tbc = "[[File:Bc icon.gif|link=]]",
	vanilla = "[[File:WoW Icon update.png|link=]]",
}

local sections = {
	{id = "tbc", label = "TBC only"},
	{id = "both", label = "TBC & Vanilla"},
	{id = "retail_tbc", label = "Retail & TBC"},
	{id = "vanilla", label = "Vanilla only"},
	{id = "retail_vanilla", label = "Retail & Vanilla"},
	{id = "retail_both", label = "Retail & TBC & Vanilla"},
}

local cvar_enum = {
	[0] = "Debug",
	[1] = "Graphics",
	[2] = "Console",
	[3] = "Combat",
	[4] = "Game",
	--[5] = "Default",
	[5] = "",
	[6] = "Net",
	[7] = "Sound",
	[8] = "Gm",
	[9] = "Reveal",
	[10] = "None",
}

local function sortLowerCase(a, b)
	return a:lower() < b:lower()
end

function m:main()
	local eventDoc = self:GetEventPayload()
	for source, info in pairs(sources) do
		local parts, data = self:GetData(source)

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
			file:write(section_fs:format(sectionInfo.label))
			for _, name in pairs(Util:SortTable(data[sectionInfo.id], info.sortFunc)) do
				local retail = parts.live[name] and wp_icons.live or ""
				local tbc = parts.tbc[name] and wp_icons.tbc or ""
				local vanilla = parts.vanilla[name] and wp_icons.vanilla or ""
				local nameLink = info.name_fs:format(name, name)
				file:write(row_fs:format(retail, tbc, vanilla, nameLink))
				if source == "event" and eventDoc[name] then
					file:write(string.format("<small>: %s</small>", eventDoc[name]))
				elseif source == "cvar" then
					local cvarInfo = parts.tbc[name] or parts.vanilla[name]
					local default, category, account, character, description = table.unpack(cvarInfo)
					local categoryName = cvar_enum[category] or ""
					local scope = account and "Account" or character and "Character" or ""
					file:write(string.format(" || %s || %s || %s || %s", default, categoryName, scope, description))
				end
				file:write("\n")
			end
		end
		file:write("|}\n")
		file:close()
	end
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
		local path = info.cache:format(branch)
		Util:CacheFile(path, info.url:format(branch))
		local fileTbl = require(path:gsub("%.lua", ""))
		local location = info.location(fileTbl)
		parts[branch] = info.map(location)
		for name in pairs(parts[branch]) do
			mainTbl[name] = true
		end
	end

	for name in pairs(mainTbl) do
		local retail = parts.live[name]
		local tbc = parts.tbc[name]
		local vanilla = parts.vanilla[name]

		if retail then
			if tbc and vanilla then
				sectionData.retail_both[name] = tbc
			elseif tbc then
				sectionData.retail_tbc[name] = tbc
			elseif vanilla then
				sectionData.retail_vanilla[name] = vanilla
			end
		else
			if tbc and vanilla then
				sectionData.both[name] = tbc
			elseif tbc then
				sectionData.tbc[name] = tbc
			elseif vanilla then
				sectionData.vanilla[name] = vanilla
			end
		end
	end
	return parts, sectionData
end

function m:GetEventPayload()
	local FrameXML = require("Documenter/FrameXML/FrameXML")
	FrameXML:LoadApiDocs("Documenter/FrameXML")
	local t = {}
	for _, event in pairs(APIDocumentation.events) do
		if event.Payload then
			local payload = event:GetPayloadString(false, false)
			if #payload>160 and (event.LiteralName:find("^CHAT_MSG") or event.LiteralName:find("^CHAT_COMBAT_MSG")) then
				payload = "''CHAT_MSG''"
			end
			t[event.LiteralName] = payload
		end
	end
	return t
end

m:main()
print("done")
