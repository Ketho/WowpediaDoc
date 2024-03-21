local Path = require "path"
local Util = require("Util.Util")
local BRANCH = "mainline"

Util:LoadDocumentation(BRANCH)
require("Documenter.Wowpedia.Wowpedia")
--require("Documenter.Tests.Tests")

local Exporter = require("Documenter/Exporter")
Exporter:ExportSystems("out/export")
print("done")
