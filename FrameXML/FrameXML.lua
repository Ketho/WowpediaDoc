require "FrameXML/Compat"

local m = {}

local missing = {
	["DamageConstantsDocumentation.lua"] = true, -- 9.0.1 (34615)
}

-- maybe should just load all files in folder instead of TOC
local not_in_toc = {
	["BountiesDocumentation.lua"] = true, -- 9.0.1 (34615)
	["CharacterCustomizationDocumentation.lua"] = true, -- 9.0.1 (34615)
}

-- these files share the same Namespace. they do have a different Name
-- apparently both Name and Namespace are not unique between files
local shared_namespaces = {
	["PlayerInfoDocumentation.lua"] = "C_PlayerInfo", -- Name = "PlayerInfo"
	["PlayerLocationDocumentation.lua"] = "C_PlayerInfo", -- Name = "PlayerLocationInfo"
}

local function LoadApiDocFile(line)
	local file = assert(loadfile("FrameXML/Blizzard_APIDocumentation/"..line))
	file()
end

function m:LoadApiDocs()
	local toc = io.open("FrameXML/Blizzard_APIDocumentation/Blizzard_APIDocumentation.toc")
	for line in toc:lines() do
		if line:find("%.lua") and not missing[line] then
			LoadApiDocFile(line)
		end
	end
	for luaFile in pairs(not_in_toc) do
		LoadApiDocFile(luaFile)
	end
	toc:close()
	require "FrameXML/MissingDocumentation"
end

return m
