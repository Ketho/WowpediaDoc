local Util = require("Util.Util")

local loader = require("WowDocLoader.WowDocLoader")
loader:main("mainline")
local m_Api_Types = require("Projects.API_Types.Api_Types")

local function explode(t)
    for k, v in pairs(t) do
        print(k, "", "", v)
    end
end

local function combine(...)
    local t = {}
    for _, v in pairs{...} do
        for k2, v2 in pairs(v) do
            table.insert(t, v2)
        end
    end
    return t
end

local function GetFunctionTypes(name)
    local t = {}
    for _, v in pairs(APIDocumentation.functions) do
        if v.Arguments then
            for _, v2 in pairs(v.Arguments) do
                if v2.Type == name then
                    table.insert(t, v)
                end
            end
        end
        if v.Returns then
            for _, v2 in pairs(v.Returns) do
                if v2.Type == name then
                    table.insert(t, v)
                end
            end
        end
    end
    return t
end

local function GetEventTypes(name)
    local t = {}
    for _, v in pairs(APIDocumentation.events) do
        if v.Payload then
            for _, v2 in pairs(v.Payload) do
                if v2.Type == name then
                    table.insert(t, v)
                end
            end
        end
    end
    return t
end

local function GetFieldTypes(name)
    local t = {}
    for _, v in pairs(APIDocumentation.fields) do
        if v.Type == name then
            table.insert(t, v)
        end
    end
    return t
end

local function GetFullName(api)
    local t = {}
    local system
    local parent
    local source
    if api.Function then
        parent = api.Function
        system = api.Function.System
        source = "api.Function"
    elseif api.Event then
        parent = api.Event
        system = api.Event.System
        source = "api.Event"
    elseif api.Table then
        parent = api.Table
        if not api.Table.System then
            system = {Name = "Systemless"}
            source = "api.Table.noSystem"
        else
            system = api.Table.System
            source = "api.Table"
        end
    elseif api.System then
        system = api.System
        source = "api.System"
    end
    if system.Namespace then
        table.insert(t, system.Namespace)
        table.insert(t, parent.Name)
        return table.concat(t, "."), parent, source
    elseif system.Name then
        table.insert(t, system.Name)
        table.insert(t, parent.Name)
        return table.concat(t, "~"), parent,source
    end
end

local function main()
    local specialTypes = m_Api_Types:GetSpecialTypes()
    for _, apiName in pairs(specialTypes) do
        print("# "..apiName)
        -- local functions = GetFunctionTypes(apiName) -- api.System
        -- local events = GetEventTypes(apiName)       -- api.System
        local fields = GetFieldTypes(apiName)          -- api.Table, api.Function, api.Event
        local t1 = combine(fields)
        for k, v in pairs(t1) do
            local fullName, parent, source = GetFullName(v)
            -- print(k, fullName, parent:GetFullName(false, false), source, v:GetFullName(false, false))
            -- print(k, parent:GetFullName(false, false))
            if apiName == "SpellIdentifier" then
                local wikitext = ": {{api|t=a|%s}}"
                print(wikitext:format(parent:GetFullName(false, false)))
            end
        end
    end
end

main()
-- /run for k, v in pairs(APIDocumentation.functions) do if v.Name == "GetAnimation" then Spew("", v) end end
