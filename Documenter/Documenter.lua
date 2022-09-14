local Path = require "path"

local constants = require(Path.join("Documenter", "constants"))
local BRANCH = "mainline_beta"

require("Util/apidoc_fixes")

local compat_folder = Path.join("Documenter", "Load_APIDocumentation")
local FrameXML = require(Path.join(compat_folder, "Loader"))
FrameXML:LoadApiDocs(compat_folder, Path.join("FrameXML", "retail", constants.LATEST_MAINLINE))

require("Documenter/Wowpedia/Wowpedia")
--require("Documenter/Tests/Tests")

 -- some kind of Enum table already exists here, get actual Enum table
require(Path.join("Documenter", "LuaEnum")):main(BRANCH)
local Exporter = require("Documenter/Exporter")
if not Wowpedia:HasMissingTypes() then
	Exporter:ExportSystems("out/export")
end
print("done")
