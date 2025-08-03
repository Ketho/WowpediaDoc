-- https://wowpedia.fandom.com/wiki/Global_functions/Classic
-- https://wowpedia.fandom.com/wiki/Events/Classic
-- https://wowpedia.fandom.com/wiki/Console_variables/Classic
local util = require("wowdoc")
local Signatures = require("Pages/ClassicCompare/Signatures")

local PRODUCT = "wowxptr" ---@type TactProduct

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
			return util:ToMap(tbl)
		end,
		name_fs = "{{apilink|t=a|%s}}",
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
		name_fs = "{{apilink|t=e|%s}}",
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
	"mainline_ptr",
	"mists",
	"vanilla",
}

-- avoid using templates as that increases page processing time
local wp_icons = {
	mainline = "{{apiexp|tww}}",
	mists = "{{apiexp|mists}}",
	vanilla = "{{apiexp|vanilla}}",
}

local sections = {
	{id = "vanilla", label = "Vanilla"},
	{id = "mists", label = "Mists"},
	{id = "both", label = "Vanilla & Mists"},
	{id = "retail_vanilla", label = "Mainline & Vanilla"},
	{id = "retail_cata", label = "Mainline & Mists"},
	{id = "retail_both", label = "Mainline & Vanilla & Mists"},
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

local function GetExpansionIconTemplate(expansions)
	local t = {"{{apiexp|"}
	local r = {}
	for _, v in pairs(expansions) do
		if v then
			table.insert(r, v.."=1")
		end
	end
	table.insert(t, table.concat(r, "|"))
	table.insert(t, "}}")
	return table.concat(t)
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
		local fileTbl = util:DownloadAndRun(
			info.url:format(branch),
			info.cache:format(branch)
		)
		local location = info.location(fileTbl)
		parts[branch] = info.map(location)
		for name in pairs(parts[branch]) do
			mainTbl[name] = true
		end
	end

	for name in pairs(mainTbl) do
		local retail = parts.mainline_ptr[name]
		local mists = parts.mists[name]
		local vanilla = parts.vanilla[name]

		if retail then
			if mists and vanilla then
				sectionData.retail_both[name] = mists
			elseif mists then
				sectionData.retail_cata[name] = mists
			elseif vanilla then
				sectionData.retail_vanilla[name] = vanilla
			end
		else
			if mists and vanilla then
				sectionData.both[name] = mists
			elseif mists then
				sectionData.mists[name] = mists
			elseif vanilla then
				sectionData.vanilla[name] = vanilla
			end
		end
	end
	return parts, sectionData
end

function m:GetEventPayload()
	util:LoadDocumentation(PRODUCT)
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

local function GetCVarDefaultText(cvar, default)
	local s
	if default then
		if #default > 0 then
			s = string.format("<code>%s</code>", default)
		end
		if #default >= 16 then
			s = string.format('<small>%s</small>', s)
		end
		if cvar:find("telemetry") then -- too long
			s = string.format('<span title="%s">...</span>', default)
		end
	end
	return s
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
		local row_fs = "|-\n| "..string.rep("%s", 2, " || ")

		for _, sectionInfo in pairs(sections) do
			if next(data[sectionInfo.id]) then
				file:write(section_fs:format(sectionInfo.label))
				for _, name in pairs(util:SortTable(data[sectionInfo.id], info.sortFunc)) do
					local expansions = {
						parts.mainline_ptr[name] and "mainline_ptr",
						parts.mists[name] and "mists",
						parts.vanilla[name] and "vanilla",
					}
					local expansionTemplate = GetExpansionIconTemplate(expansions)
					local nameLink
					if source == "api" then
						nameLink = Signatures.wow_classic_era[name] or Signatures.wow_classic[name] or Signatures.wowxptr[name] or string.format("{{apilink|t=a|%s|noparens=1}}", name)
					else
						nameLink = info.name_fs:format(name, name)
					end
					file:write(row_fs:format(expansionTemplate, nameLink))
					if source == "event" and eventDoc[name] then
						file:write(string.format("<small>: %s</small>", eventDoc[name]))
					elseif source == "cvar" then
						local cvarInfo = parts.mists[name] or parts.vanilla[name]
						local default, category, account, character, secure, description = table.unpack(cvarInfo)
						local default_text = GetCVarDefaultText(name, default) or ""
						local categoryName = cvar_enum[category] or ""
						local scope = account and "Account" or character and "Character" or ""
						description = description:gsub("|", "&#124;")
						file:write(string.format(" || %s || %s || %s || %s", default_text, categoryName, scope, description))
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
