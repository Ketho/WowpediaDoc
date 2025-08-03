-- 1. load vanilla and classic docs
-- 2. generate their api signatures
-- 3. return them

local Path = require("path")
local util = require("wowdoc")
local WowDocLoader = require("WowDocLoader")

---@type table<TactProduct, table>
local signatures = {
    wowxptr = {},
    wow_classic = {},
    wow_classic_era = {},
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
