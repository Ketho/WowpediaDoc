local FrameXML = require("FrameXML/FrameXML")
FrameXML:LoadApiDocs("FrameXML")

require "Wowpedia/Wowpedia"
require "Tests/Tests"

local Exporter = require("Exporter")
if not Wowpedia:HasMissingTypes() then
	Exporter:ExportSystems("out")
end
