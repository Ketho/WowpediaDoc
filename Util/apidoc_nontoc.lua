-- when we dont need the Blizzard_APIDocumentation addon
local lfs = require "lfs"
local Util = require "Util/Util"

local m = {}
local docTables = {}

APIDocumentation = {}

function APIDocumentation:AddDocumentationTable(info)
	table.insert(docTables, info)
end

-- used in CurrencyConstantsDocumentation.lua
Enum = {
	PlayerCurrencyFlagsDbFlags = {
		InBackpack = 0,
		UnusedInUI = 0,
	},
}

local nondoc = {
	["."] = true,
	[".."] = true,
	["Blizzard_APIDocumentation.lua"] = true,
	["Blizzard_APIDocumentation.toc"] = true,
	["Blizzard_APIDocumentationGenerated.toc"] = true,
	["EventsAPIMixin.lua"] = true,
	["FieldsAPIMixin.lua"] = true,
	["FunctionsAPIMixin.lua"] = true,
	["SystemsAPIMixin.lua"] = true,
	["TablesAPIMixin.lua"] = true,
}

-- doc files are not removed in >=2.5.1 but rather removed from TOC
local removed_from_toc = {
	["2.5.1"] = {
		["RecruitAFriendDocumentation.lua"] = true,
	},
	["2.5.2"] = {
		["ClubDocumentation.lua"] = true,
		["RecruitAFriendDocumentation.lua"] = true,
	},
}

local function IsTocRemoved(fileName, version)
	local key = removed_from_toc[version]
	return key and key[fileName]
end

function m:LoadBlizzardDocs(folder)
	Util:Wipe(docTables)
	local version = folder:match("%d+%.%d+.%d+")
	for fileName in lfs.dir(folder) do
		if not nondoc[fileName] and not IsTocRemoved(fileName, version) then
			loadfile(folder.."/"..fileName)()
		end
	end
	return Util:CopyTable(docTables)
end

return m
