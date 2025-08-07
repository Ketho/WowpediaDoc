local pathlib = require("path")

local wowdocloader = require("wowdoc.loader")

-- use the TACT product as starting point
local PRODUCT = "wow" ---@type TactProduct
wowdocloader:main(PRODUCT)
require("Documenter.Wowpedia")
--require("Documenter.Tests.Tests")

local Exporter = require("Documenter.Exporter")
Exporter:ExportSystems(pathlib.join("out", "export"))
