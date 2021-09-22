-- experimental, bad code
-- note APIDocumentation gets overwritten again
ApiDocsDiff = require("Projects/ApiDocsDiff/ApiDocsDiff")

-- bad hack, to do: refactor
local FrameXML = require("Documenter/FrameXML/FrameXML")
FrameXML:LoadApiDocs("Documenter/FrameXML", "FrameXML/retail/9.1.5.40071")

require("Documenter/Wowpedia/Wowpedia")
--require("Documenter/Tests/Tests")

local Exporter = require("Documenter/Exporter")
if not Wowpedia:HasMissingTypes() then
	Exporter:ExportSystems("out/export")
end
