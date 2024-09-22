local ParseAnnotations = require("Pages/World of Warcraft API/ParseAnnotations/ParseAnnotations")

local wiki_data = ParseAnnotations:main()

local m = {}

function m:BuildSignature()
    local t = {}
    for k, v in pairs(wiki_data) do
        if not v.nopage then
            t[v.name] = self:FormatSignature(v)
            -- print(k, v)
        end
    end
    return t
end

local function GetArguments(args)
    if args then
        local t = {}
        for _, arg in ipairs(args) do
            table.insert(t, arg.name)
        end
        return table.concat(t, ", ")
    else
        return ""
    end
end

local function GetReturns(rets)
    if rets then
        local t = {}
        for _, ret in ipairs(rets) do
            table.insert(t, ret.name)
        end
        return table.concat(t, ", ")
    else
        return ""
    end
end

local function FomatOptionals(paramTbl)
	local tbl = {}
    local numOptionals = 0
    for _, param in ipairs(paramTbl) do
        local name = param.name
        if param.nilable then
            numOptionals = numOptionals + 1
            name = format("[%s", name)
        else
            name = format("%s", name)
        end
        tinsert(tbl, name)
    end
    local str = table.concat(tbl, ", ")
    local result
    if numOptionals > 0 then
        result = str..string.rep("]", numOptionals)
        result = result:gsub(", %[", " [, ")
    else
        result = str
    end
    return result
end

function m:FormatSignature(info)
	local t = {}
	local fs_base = '[[API %s|%s]](%s)%s'
	local fs_args = '<span class="apiarg">%s</span>'
	local fs_returns = ' : <span class="apiret">%s</span>'
    local args, rets = "", ""
    if info.arg then
        args = fs_args:format(FomatOptionals(info.arg))
    end
    if info.ret then
        rets = fs_returns:format(GetReturns(info.ret))
    end
    return fs_base:format(info.name, info.name, args, rets)
end

function m:main()
    local data = self:BuildSignature()
    return data
end

-- m:main()
return m
