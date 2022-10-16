local lfs = require "lfs"
local Path = require "path"
local Util = require "Util.Util"
local constants = require("Documenter.constants")
require("Util.apidoc_fixes")
local m = {}

local function LoadFile(path)
	if lfs.attributes(path) then
		local file = loadfile(path)
		file()
	end
end

local function LoadAddon(addons_folder, name)
	local folder = Path.join(addons_folder, name)
	local file = io.open(Path.join(folder, name..".toc"))
	if file then
		for line in file:lines() do
			if line:find("%.lua") then
				LoadFile(Path.join(folder, line))
			end
		end
		file:close()
	end
end

function m:main(flavor)
	local loader_folder = Path.join("Documenter", "Load_APIDocumentation")
	local addons_folder
	if flavor:find("mainline") then
		addons_folder = Path.join(Util:GetLatestBuild("mainline"), "AddOns")
	elseif flavor == "classic" then
		addons_folder = Path.join(Util:GetLatestBuild("classic"), "Interface", "AddOns")
	end
	require(Path.join(loader_folder, "Compat"))
	LoadAddon(addons_folder, "Blizzard_APIDocumentation")
	require(Path.join(loader_folder, "MissingDocumentation"))
	LoadAddon(addons_folder, "Blizzard_APIDocumentationGenerated")
end

return m

--[[
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

local missing = {
	-- ["CurrencyConstantsDocumentation.lua"] = true, -- 9.0.2 (36165)
}
]]
