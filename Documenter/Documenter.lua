local util = require("util")

-- use the TACT product as starting point
local PRODUCT = "wow" ---@type TactProduct
util:LoadDocumentation(PRODUCT)

require("Documenter.Wowpedia.Wowpedia")
--require("Documenter.Tests.Tests")

local Exporter = require("Documenter/Exporter")
Exporter:ExportSystems("out/export")
print("done")
