local Util = require("Util/Util")

-- mainline, ptr, tbc, vanilla
local FLAVOR = "mainline"
local options = Util:GetFlavorOptions(FLAVOR)
require("Projects.UpdateResources.GlobalStrings")(options)
require("Projects.UpdateResources.AtlasInfo")(options)

local DumbXmlParser = require("Projects.DumbXmlParser.DumbXmlParser")
DumbXmlParser:main(options.flavor)

print("done")
