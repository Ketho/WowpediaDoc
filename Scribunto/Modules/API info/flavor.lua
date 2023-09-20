local bit = require "bit32"
local data
local m = {}

-- cant use dots in github search
-- https://docs.github.com/en/github/searching-for-information-on-github/searching-on-github/searching-code#considerations-for-code-search
local function GetApiBaseName(v)
	if v:find("%.") then
		v = v:match(".-%.(.+)")
	end
	return v
end

-- github forks are not searchable unless they have more stars, just cloned it instead
-- https://stackoverflow.com/questions/33626326/how-to-search-a-github-fork-for-code-using-the-github-search-api
local flavors = {
	mainline = {
		label = "mainline",
		flag = 0x1,
		icon = {name = "Dragonflight-Icon-Inline.png", size = 36},
		url = "https://github.com/search?q=repo:Gethe/wow-ui-source+%s&type=code",
	},
	vanilla = {
		label = "vanilla",
		flag = 0x2,
		icon = {name = "WoW Icon update.png", size = 36},
		url = "https://github.com/search?q=repo:Ketho/wow-ui-source-vanilla+%s&type=code",
	},
	wrath = {
		label = "wrath",
		flag = 0x4,
		icon = {name = "Wrath-Logo-Small.png", size = 36},
		url = "https://github.com/search?q=repo:Ketho/wow-ui-source-wrath+%s&type=code",
	},
}

local function GetData(apiType)
	local api_types = {
		a = "api",
		e = "event",
	}
	if api_types[apiType] then
		return {[apiType] = mw.loadData("Module:API_info/flavor/"..api_types[apiType])}
	end
end

function m:GetFlavorInfo(apiType, name)
	data = data or GetData(apiType)
	local flags = data[apiType][name]
	if flags then
		local mainline = bit.band(flags, flavors.mainline.flag) > 0
		local vanilla = bit.band(flags, flavors.vanilla.flag) > 0
		local wrath = bit.band(flags, flavors.wrath.flag) > 0
		return flags, mainline, vanilla, wrath, mainline_beta
	end
end

local function InsertTableInfo(tbl, name, info)
	-- local baseName = GetApiBaseName(name)
	table.insert(tbl, {
		icon = info.icon.name,
		iconsize = info.icon.size,
		url = info.url:format(name),
		text = info.label,
	})
end

function m:GetFlavors(apiType, name)
	data = data or GetData(apiType)
	local flags, mainline, vanilla, wrath, mainline_beta = self:GetFlavorInfo(apiType, name)
	if flags then
		local t = {}
		if mainline then
			InsertTableInfo(t, name, flavors.mainline)
		end
		if wrath then
			InsertTableInfo(t, name, flavors.wrath)
		end
		if vanilla then
			InsertTableInfo(t, name, flavors.vanilla)
		end
		return t
	end
end

return m
