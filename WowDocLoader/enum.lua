-- Blizzard_APIDocumentationGenerated requires the `Enum` table
local util = require("util")
local pathlib = require("path")
local log = require("util.log")

local m = {}
local REPO = "https://raw.githubusercontent.com/Ketho/BlizzardInterfaceResources"

local function ApplyFixes()
    -- Meta fields are not written to LuaEnum.lua
    Enum.LFGRoleMeta = {NumValue = 3} -- 10.2.5 LFGConstantsDocumentation.lua

    --[[
    if not MAX_STABLE_SLOTS then -- 10.2.7
        MAX_STABLE_SLOTS = -1
        EXTRA_PET_STABLE_SLOT = -1
        NUM_PET_SLOTS_THAT_NEED_LEARNED_SPELL = -1
    end

    if Constants then -- 11.0.2
        Constants.PetConsts = {
            MAX_STABLE_SLOTS = -1,
            EXTRA_PET_STABLE_SLOT = -1,
            NUM_PET_SLOTS_THAT_NEED_LEARNED_SPELL = -1,
        }
    end
    ]]
end

function m:LoadLuaEnums(branch)
	if Enum then
		log:warn("WowDocLoader: `Enum` already loaded")
		return
	end
	util:MakeDir("cache_lua")
    local path = pathlib.join("cache_lua", string.format("LuaEnum_%s.lua", branch))
	local url = string.format("%s/%s/Resources/LuaEnum.lua", REPO, branch)
	util:DownloadAndRun(path, url)
    ApplyFixes()
end

return m
