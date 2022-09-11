local Util = require("Util/Util")
local m = {}

local PATH = "cache_lua/LuaEnum_%s.lua"
local URL = "https://raw.githubusercontent.com/Ketho/BlizzardInterfaceResources/%s/Resources/LuaEnum.lua"

function m:main(branch)
	local path = PATH:format(branch)
	local url = URL:format(branch)
	Util:DownloadAndRun(path, url)
end

return m
