local constants = require("Documenter/constants")

-- experimental, bad code
-- note APIDocumentation gets overwritten again
-- API_patchdiff = require("Projects/API_patchdiff/API_patchdiff")

-- bad hack, to do: refactor
local FrameXML = require("Documenter/FrameXML/FrameXML")
FrameXML:LoadApiDocs("Documenter/FrameXML", "FrameXML/retail/"..constants.LATEST_MAINLINE)

require("Documenter/Wowpedia/Wowpedia")
--require("Documenter/Tests/Tests")

local Exporter = require("Documenter/Exporter")
if not Wowpedia:HasMissingTypes() then
	Exporter:ExportSystems("out/export")
end
print("done")
