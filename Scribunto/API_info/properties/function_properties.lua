---@diagnostic disable: need-check-nil
local pathlib = require("path")
local widget_docs = require("util.widget_system")
local log = require("util.log")

local properties = {
    MayReturnNothing = 0,
    IsProtectedFunction = 1,
    HasRestrictions = 2,
    RequiresValidAndPublicCVar = 10,
    RequiresNonReadOnlyCVar = 11,
    RequiresNonSecureCVar = 12,
    RequiresIndexInRange = 13,
    RequiresValidInviteTarget = 20,
    RequiresFriendList = 30,
    RequiresClubsInitialized = 40,
    RequiresCommentator = 50,
    RequiresActiveCommentator = 51,
}

local PRODUCT = "wowxptr" ---@type TactProduct
local wowdoc = require("WowDocLoader")
wowdoc:main(PRODUCT)

local function GetFullName(apiTable)
    if apiTable.System then
        if apiTable.System.Type == "System" then
            if apiTable.System.Namespace then
                return string.format("%s.%s", apiTable.System.Namespace, apiTable.Name)
            else
                return apiTable.Name
            end
        elseif apiTable.System.Type == "ScriptObject" then
            local widget = widget_docs[apiTable.System.Name]
            return string.format("%s %s", widget, apiTable.Name)
        end
    end
end

local function SortProperties(a, b)
    return properties[a] < properties[b]
end


local function ProcessDocs()
    local t0 = {}
    for _, v in pairs(APIDocumentation.functions) do
        local t1 = {}
        -- want to preserve the same order as in blizzard docs
        for attrib in pairs(properties) do
            if v[attrib] then
                table.insert(t1, attrib)
            end
        end
        if #t1 > 0 then
            table.sort(t1, SortProperties)
            local t2 = {}
            for k2 in pairs(t1) do
                local stringified = string.format('"%s"', t1[k2])
                table.insert(t2, stringified)
            end
            local name = GetFullName(v)
            local propNames = table.concat(t2, ", ")
            local line = string.format('\t["%s"] = { %s },\n', name, propNames)
            table.insert(t0, line)
        end
    end
    table.sort(t0)
    return t0
end

local function main()
    local output = pathlib.join("out", "lua", "API_info.properties.lua")
    local file = io.open(output, "w")


    file:write("local m = {}\n\n")
    file:write("m.data = {\n")

    local t = ProcessDocs()
    for _, v in pairs(t) do
        file:write(v)
    end

    file:write("}\n\n")
    file:write("return m\n")
    file:close()
    log:success("Done")
end

main()