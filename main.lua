local BASE = "FrameXML"
local FrameXML = require(BASE.."/FrameXML")
FrameXML:LoadApiDocs(BASE)

require "Wowpedia/Wowpedia"
require "Tests/Tests"

local Exporter = require("Exporter")
Exporter:ExportSystems("out")
