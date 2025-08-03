local log = require("wowdoc.log")
local git = require("wowdoc.git")
local products = require("wowdoc.products")
local wago = require("wowdoc.wago")

OUT_GLOBALSTRINGS = "/mnt/d/Repo/wow-api/BlizzardInterfaceResources/Resources/GlobalStrings/%s.lua"
OUT_ATLAS = "/mnt/d/Repo/wow-api/BlizzardInterfaceResources/Resources/AtlasInfo.lua"
OUT_RESOURCES = "/mnt/d/Repo/wow-api/BlizzardInterfaceResources/Resources"
IN_FRAMEXML = "./wow-ui-source/"

local globalstrings = require("Projects.UpdateResources.GlobalStrings")
local atlasinfo = require("Projects.UpdateResources.AtlasInfo")
local dumbparser = require("Projects.DumbXmlParser")

local PRODUCT = "wow" ---@type TactProduct
local branch = products:GetBranch(PRODUCT)
git:checkout("https://github.com/Gethe/wow-ui-source", branch)

local latestBuild = wago:GetLatestBuild(PRODUCT) -- want the latest build number for caching the csv
log:success(string.format("Latest wago build for product: %s", latestBuild))
local options = {build = latestBuild, header = true}

log:info("Updating GlobalStrings")
globalstrings:WriteLocales(options)

log:info("Updating AtlasInfo")
atlasinfo:WriteAtlases(options)

log:info("Parsing FrameXML for mixins and templates")
dumbparser:ParseFrameXML()

log:success("Done")
