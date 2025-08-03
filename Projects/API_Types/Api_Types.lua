local util = require("wowdoc")

local loader = require("WowDocLoader.WowDocLoader")
loader:main("mainline")

local m = {}

local function explode(t)
    for k, v in pairs(t) do
        print(k, v)
    end
end

local function union(...)
    local t = {}
    for _, v in pairs{...} do
        for k in pairs(v) do
            t[k] = true
        end
    end
    return t
end

local function difference(a, b)
    local t = {}
    for k in pairs(a) do
        if not b[k] then
            t[k] = true
        end
    end
    return t
end

local function GetStructureTypes()
    local t = {}
    for k, v in pairs(APIDocumentation.tables) do
        if v.Type == "Structure" or v.Type == "CallbackType" then
            t[v.Name] = true
        end
    end
    return t
end

local function GetEnumTypes()
    local t = {}
    for k in pairs(Enum) do
        t[k] = true
    end
    return t
end

local function GetFunctionTypes()
    local t = {}
    for _, v in pairs(APIDocumentation.functions) do
        if v.Arguments then
            for _, v2 in pairs(v.Arguments) do
                t[v2.Type] = true
            end
        end
        if v.Returns then
            for _, v2 in pairs(v.Returns) do
                t[v2.Type] = true
            end
        end
    end
    return t
end

local function GetEventTypes()
    local t = {}
    for _, v in pairs(APIDocumentation.events) do
        if v.Payload then
            for _, v2 in pairs(v.Payload) do
                t[v2.Type] = true
            end
        end
    end
    return t
end

local function GetFieldTypes()
    local t = {}
    for _, v in pairs(APIDocumentation.fields) do
        t[v.Type] = true
    end
    return t
end

local basicTypes = {
    bool = true,
    luaFunction = true,
    number = true,
    string = true,
    table = true,
    cstring = true,
    luaIndex = true,
}

local missingStructures = {
    AuraData = true,
    TooltipComparisonItem = true,
    TooltipData = true,
    UiMapPoint = true,
}

-- 11.0.2: these seem to be defined in the docs but dont exist
local docNoExistEnums = {
    ConfigurationWarning = true,
    WarbandEventState = true,
    WarbandGroupFlags = true,
    WarbandSceneAnimationEvent = true,
    WarbandSceneAnimationSheatheState = true,
    WarbandSceneAnimationStandState = true,
    WarbandSceneSlotType = true,
}

local mixins = {
    AzeriteEmpoweredItemLocation = 
    true,
    AzeriteItemLocation = true,
    colorRGB = true,
    colorRGBA = true,
    EmptiableItemLocation = true,
    ItemLocation = true,
    ItemTransmogInfo = true,
    PlayerLocation = true,
    ReportInfo = true,
    TransmogLocation = true,
    TransmogPendingInfo = true,
    vector2 = true,
    vector3 = true,
}

local widgets = {
    CScriptObject = true,
    ModelSceneFrame = true,
    ModelSceneFrameActor = true,
    NamePlateFrame = true,
    ScriptRegion = true,
    SimpleAnim = true,
    SimpleAnimGroup = true,
    -- SimpleButtonStateToken = true,
    SimpleControlPoint = true,
    SimpleFont = true,
    SimpleFontString = true,
    SimpleFrame = true,
    SimpleLine = true,
    SimpleMaskTexture = true,
    SimplePathAnim = true,
    SimpleTexture = true,
    SimpleWindow = true,
}

function m:GetSpecialTypes()
    local structures = GetStructureTypes()
    local enums = GetEnumTypes()
    local functions = GetFunctionTypes()
    local events = GetEventTypes()
    local fields = GetFieldTypes()

    local t1 = union(structures, missingStructures, enums, docNoExistEnums, basicTypes, mixins, widgets)
    local t2 = union(functions, events, fields)
    local types = difference(t2, t1)
    local sorted = util:SortTable(types)
    return sorted
end

local function main()
    local sorted = m:GetSpecialTypes()
    for k, v in pairs(sorted) do
        print(v)
    end
end
-- main()

return m
