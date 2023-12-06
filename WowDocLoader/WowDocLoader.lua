local Path = require "path"
local Util = require("Util.Util")
WowDocLoader_Path = Path.join("WowDocLoader")
local WowDocLoader = {}

function WowDocLoader:main(base_path, flavor)
	AddOns_Path = base_path
	local Loader = require(Path.join(WowDocLoader_Path, "Loader"))
	Loader:main()
	-- for k, v in pairs(APIDocumentation.systems) do
	-- 	print(k, v.Name)
	-- end
end

if not debug.getinfo(3) then -- running this file directly
	WowDocLoader:main("WowDocLoader")
else
	return WowDocLoader
end
