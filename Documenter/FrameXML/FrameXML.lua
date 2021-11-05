local lfs = require "lfs"
local constants = require("FrameXML/constants")
local m = {}

local missing = {
	-- ["CurrencyConstantsDocumentation.lua"] = true, -- 9.0.2 (36165)
}

-- documentation that was moved to another file
-- but still has used structures that only exist in the old file which is not loaded from TOC
local not_in_toc = {
	["BountiesDocumentation.lua"] = "QuestLogDocumentation.lua", -- 9.0.1 (34615)
	["CharacterCustomizationDocumentation.lua"] = "BarberShopDocumentation.lua", --  9.0.1 (34615)
}

-- these files share the same Namespace. they do have a different Name
-- apparently both Name and Namespace are not unique between files
local shared_namespaces = {
	["PlayerInfoDocumentation.lua"] = "C_PlayerInfo", -- Name = "PlayerInfo"
	["PlayerLocationDocumentation.lua"] = "C_PlayerInfo", -- Name = "PlayerLocationInfo"
}

local function LoadApiDocFile(base, line)
	local path = base.."/Blizzard_APIDocumentation/"..line
	if lfs.attributes(path) then
		local file = loadfile(path)
		file()
	end
end

function m:LoadApiDocs(base, latestFrameXML)
	-- huh what did I do here
	if not latestFrameXML then
		latestFrameXML = "FrameXML/retail/"..constants.LATEST_MAINLINE
	end
	require(base.."/Compat")
	local toc = io.open(latestFrameXML.."/Blizzard_APIDocumentation/Blizzard_APIDocumentation.toc")
	if toc then
		for line in toc:lines() do
			if line:find("%.lua") and not missing[line] then
				LoadApiDocFile(latestFrameXML, line)
			end
		end
		toc:close()
	end
	require(base.."/MissingDocumentation")
end

return m
