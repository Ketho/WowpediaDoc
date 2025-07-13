local log = require("util.log")
local products = require("util.products")

local REPO = "https://github.com/Gethe/wow-ui-source"
local PRODUCT = products.products.wowxptr
-- local BRANCH = "ptr2"

if BRANCH then
    log:success(string.format("Branch: %s", BRANCH))
elseif PRODUCT then
    BRANCH = products.product_branch[PRODUCT]
    log:success(string.format("Product: %s", PRODUCT))
    log:success(string.format("Branch: %s", BRANCH))
else
    error("no branch or product specified")
end

local util = require("util")
local git = require("util.git")
git:pull(REPO, BRANCH)

util:LoadDocumentation(BRANCH)
-- require("Documenter.Wowpedia.Wowpedia")
-- --require("Documenter.Tests.Tests")

-- local Exporter = require("Documenter/Exporter")
-- Exporter:ExportSystems("out/export")
-- print("done")
