local FrameXML = require("Documenter/FrameXML/FrameXML")
FrameXML:LoadApiDocs("Documenter/FrameXML")

require("Documenter/Wowpedia/Wowpedia")
--require("Documenter/Tests/Tests")

local Exporter = require("Documenter/Exporter")
if not Wowpedia:HasMissingTypes() then
	Exporter:ExportSystems("out/export")
end
