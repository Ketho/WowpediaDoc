-- https://wowpedia.fandom.com/wiki/Global_functions/Classic
-- https://wowpedia.fandom.com/wiki/Events/Classic
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
		fs = "[[API %s|%s]]",
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
		fs = "[[%s]]",
	},
}

local branches = {
	"live",
	"classic",
	"classic_beta",
}

-- avoid using templates as that increases page processing time
local wp_icons = {
	live = "[[File:Shadowlands-Logo-Small.png|34px|link=]]",
	bcc = "[[File:Bc icon.gif|link=]]",
	classic = "[[File:WoW Icon update.png|link=]]",
}

local sections = {
	{id = "bcc", label = "BCC only"},
	{id = "both", label = "BCC & Classic"},
	{id = "retail_bcc", label = "Retail & BCC"},
	{id = "classic", label = "Classic only"},
	{id = "retail_classic", label = "Retail & Classic"},
	{id = "retail_both", label = "Retail & BCC & Classic"},
}

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

	for _, name in pairs(Util:SortTable(mainTbl)) do
		local retail = parts.live[name]
		local bcc = parts.classic_beta[name]
		local classic = parts.classic[name]

		if retail then
			if bcc and classic then
				sectionData.retail_both[name] = true
			elseif bcc then
				sectionData.retail_bcc[name] = true
			elseif classic then
				sectionData.retail_classic[name] = true
			end
		else
			if bcc and classic then
				sectionData.both[name] = true
			elseif bcc then
				sectionData.bcc[name] = true
			elseif classic then
				sectionData.classic[name] = true
			end
		end
	end
	return parts, sectionData
end

function m:main()
	local eventDoc = self:GetEventPayload()
	for source, info in pairs(sources) do
		local parts, data = self:GetData(source)

		local file = io.open(info.out, "w")
		file:write('{| class="sortable darktable zebra"\n')
		file:write(string.format('! !! !! !! align="left" | %s\n', info.label))

		local section_fs = '|-\n! colspan="4" style="text-align:left; padding-left: 9em;" | %s\n'
		local row_fs = "|-\n| %s || %s || %s || %s"

		for _, sectionInfo in pairs(sections) do
			file:write(section_fs:format(sectionInfo.label))
			for _, name in pairs(Util:SortTable(data[sectionInfo.id])) do
				local retail = parts.live[name] and wp_icons.live or ""
				local bcc = parts.classic_beta[name] and wp_icons.bcc or ""
				local classic = parts.classic[name] and wp_icons.classic or ""
				local nameLink = info.fs:format(name, name)
				file:write(row_fs:format(retail, bcc, classic, nameLink))
				if source == "event" and eventDoc[name] then
					file:write(string.format("<small>: %s</small>", eventDoc[name]))
				end
				file:write("\n")
			end
		end
		file:write("|}\n")
		file:close()
	end
end

m:main()
print("done")
