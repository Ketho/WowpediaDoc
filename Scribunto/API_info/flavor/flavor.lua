-- https://wowpedia.fandom.com/wiki/Module:API_info/flavor/api
-- https://wowpedia.fandom.com/wiki/Module:API_info/flavor/event
local Util = require("Util/Util")
Util:MakeDir("cache_lua")

local flavor = {
	mainline = 0x1,
	vanilla = 0x2,
	wrath = 0x4,
	mainline_beta = 0x8,
}

local m = {}

local sources = {
	api = {
		url = "https://raw.githubusercontent.com/Ketho/BlizzardInterfaceResources/%s/Resources/GlobalAPI.lua",
		cache = "cache_lua/GlobalAPI_%s.lua",
		out = "out/lua/API_info.flavor.api.lua",
		location = function(tbl)
			return tbl[1]
		end,
		map = function(tbl)
			return Util:ToMap(tbl)
		end,
	},
	event = {
		url = "https://raw.githubusercontent.com/Ketho/BlizzardInterfaceResources/%s/Resources/Events.lua",
		cache = "cache_lua/Events_%s.lua",
		out = "out/lua/API_info.flavor.event.lua",
		location = function(tbl)
			return tbl
		end,
		map = function(tbl)
			local t = {}
			for _, events in pairs(tbl) do
				for _, event in pairs(events) do
					t[event] = true
				end
			end
			return t
		end,
	},
}

-- https://github.com/Ketho/BlizzardInterfaceResources/branches
local branches = {
	"mainline",
	"vanilla",
	"wrath",
	"mainline_beta",
}

function m:GetData(sourceType)
	local info = sources[sourceType]
	local parts = {}
	local data = {}
	for _, branch in pairs(branches) do
		local fileTbl = Util:DownloadAndRun(
			info.cache:format(branch),
			info.url:format(branch)
		)
		local location = info.location(fileTbl)
		parts[branch] = info.map(location)
		for name in pairs(parts[branch]) do
			data[name] = true
		end
	end
	for k in pairs(data) do
		local mainline = parts.mainline[k] and flavor.mainline or 0
		local vanilla = parts.vanilla[k] and flavor.vanilla or 0
		local wrath = parts.wrath[k] and flavor.wrath or 0
		local mainline_beta = parts.mainline_beta[k] and flavor.mainline_beta or 0
		data[k] = mainline | vanilla | wrath | mainline_beta
	end
	return data
end

local function main()
	for source, info in pairs(sources) do
		local data = m:GetData(source)
		print("writing to", info.out)
		local file = io.open(info.out, "w")
		file:write('local data = {\n')
		for _, name in pairs(Util:SortTable(data)) do
			local flavors = data[name]
			file:write(string.format('\t["%s"] = 0x%X,\n', name, flavors))
		end
		file:write("}\n\nreturn data\n")
		file:close()
	end
end

main()
print("done")
