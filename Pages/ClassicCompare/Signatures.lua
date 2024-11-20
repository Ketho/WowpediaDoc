-- 1. load vanilla and cata docs
-- 2. generate their api signatures
-- 3. return them

local Path = require "path"
local Util = require("Util.Util")
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
        local fullName = Util:api_func_GetFullName(v)
        -- print(k, Util:api_func_GetFullName(v), Util:template_apilink("a", v))
        signatures[flavor][fullName] = Util:template_apilink("a", v)
    end
end

return signatures
