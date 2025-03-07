local Util = require("Util/Util")

-- fuck I'm writing from wsl to the windows filesystem
-- this is a horrible mess
IN_FRAMEXML = "/mnt/d/Repo/wow-api/wow-ui-source/"
OUT_GLOBALSTRINGS = "/mnt/d/Repo/wow-api/BlizzardInterfaceResources/Resources/GlobalStrings/%s.lua"
OUT_RESOURCES = "/mnt/d/Repo/wow-api/BlizzardInterfaceResources/Resources"
OUT_ATLAS = "/mnt/d/Repo/wow-api/BlizzardInterfaceResources/Resources/AtlasInfo.lua"

-- mainline, mainline_ptr, cata, vanilla
local FLAVOR = "mainline_ptr"
local options = Util:GetFlavorOptions(FLAVOR)

-- local options = Util:GetFlavorOptions({build="10.2.7.55664", header = true})
require("Projects.UpdateResources.GlobalStrings")(options)
require("Projects.UpdateResources.AtlasInfo")(options)

local DumbXmlParser = require("Projects.DumbXmlParser.DumbXmlParser")
DumbXmlParser:main(options.flavor)

print("done")
