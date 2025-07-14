-- 1. load vanilla and cata docs
-- 2. generate their api signatures
-- 3. return them

local Path = require("path")
local util = require("util")
local WowDocLoader = require("WowDocLoader.WowDocLoader")

local signatures = {
    mainline = {},
    cata = {},
    vanilla = {},
}

for flavor in pairs(signatures) do
    APIDocumentation = nil
    WowDocLoader:main(flavor)
    for k, v in pairs(APIDocumentation.functions) do
        local fullName = util:api_func_GetFullName(v)
        -- print(k, util:api_func_GetFullName(v), util:template_apilink("a", v))
        signatures[flavor][fullName] = util:template_apilink("a", v)
    end
end

return signatures
