local pathlib = require("path")

local wowdocloader = require("WowDocLoader")

-- use the TACT product as starting point
local PRODUCT = "wowxptr" ---@type TactProduct
wowdocloader:main(PRODUCT)
require("Documenter.Wowpedia")
--require("Documenter.Tests.Tests")

local Exporter = require("Documenter.Exporter")
Exporter:ExportSystems(pathlib.join("out", "export"))
