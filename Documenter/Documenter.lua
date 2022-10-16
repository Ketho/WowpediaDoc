local Path = require "path"
local BRANCH = "mainline_beta"

require("Documenter.LuaEnum"):main(BRANCH)
require("Documenter.Load_APIDocumentation.Loader"):main(BRANCH)
require("Documenter.Wowpedia.Wowpedia")
--require("Documenter.Tests.Tests")

local Exporter = require("Documenter/Exporter")
if not Wowpedia:HasMissingTypes() then
	Exporter:ExportSystems("out/export")
end
print("done")
