local util = require("util")
local log = require("util.log")
local products = require("util.products")
local git = require("util.git")

-- the starting point will be the TACT product
local PRODUCT = "wow" ---@type TactProduct
local FRAMEXML_BRANCH = products.gethe_branch[PRODUCT]
local BLIZZRES_BRANCH = products.blizzres_branch[PRODUCT]

if PRODUCT and #PRODUCT > 0 then
    log:success(string.format("TACT product: %s", PRODUCT))
end
if FRAMEXML_BRANCH and #FRAMEXML_BRANCH > 0 then
    log:success(string.format("Gethe branch: %s", FRAMEXML_BRANCH))
end
if BLIZZRES_BRANCH and #BLIZZRES_BRANCH > 0 then
    log:success(string.format("BlizzRes branch: %s", BLIZZRES_BRANCH))
end

git:pull("https://github.com/Gethe/wow-ui-source", FRAMEXML_BRANCH)

util:LoadDocumentation(BLIZZRES_BRANCH)
require("Documenter.Wowpedia.Wowpedia")
--require("Documenter.Tests.Tests")

local Exporter = require("Documenter/Exporter")
Exporter:ExportSystems("out/export")
print("done")
