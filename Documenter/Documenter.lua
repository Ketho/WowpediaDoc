local Path = require "path"
local Util = require("Util.Util")
local BRANCH = "mainline"

require("Documenter.LuaEnum"):main(BRANCH)
local addons_path = Path.join(Util:GetLatestBuild("mainline"), "AddOns")
require("WowDocLoader.WowDocLoader"):main("WowDocLoader", addons_path)
require("Documenter.Wowpedia.Wowpedia")
--require("Documenter.Tests.Tests")

local Exporter = require("Documenter/Exporter")
if not Wowpedia:HasMissingTypes() then
	Exporter:ExportSystems("out/export")
end
print("done")
