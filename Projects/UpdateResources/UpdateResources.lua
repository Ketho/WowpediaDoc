local Util = require("Util/Util")

-- mainline, ptr, wrath, tbc, vanilla
local FLAVOR = "mainline_ptr"
local options = Util:GetFlavorOptions(FLAVOR)
require("Projects.UpdateResources.GlobalStrings")(options)
require("Projects.UpdateResources.AtlasInfo")(options)

local DumbXmlParser = require("Projects.DumbXmlParser.DumbXmlParser")
DumbXmlParser:main(options.flavor)

print("done")
