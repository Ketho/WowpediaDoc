local Util = require("Util/Util")

-- mainline, tbc, vanilla
local FLAVOR = "mainline"
local options = Util:GetFlavorOptions(FLAVOR)
require("Projects.UpdateResources.GlobalStrings")(options)
require("Projects.UpdateResources.AtlasInfo")(options)

local DumbXmlParser = require("Projects.DumbXmlParser.DumbXmlParser")
DumbXmlParser:main(FLAVOR)

print("done")