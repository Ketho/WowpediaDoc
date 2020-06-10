local FrameXML = require("FrameXML/FrameXML")
FrameXML:LoadApiDocs()

require "Wowpedia/Wowpedia"
require "Tests/Tests"

local Exporter = require("Exporter")
Exporter:ExportSystems("out")
