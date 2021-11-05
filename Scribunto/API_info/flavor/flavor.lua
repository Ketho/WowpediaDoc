-- https://wowpedia.fandom.com/wiki/Module:API_info/flavor/api
-- https://wowpedia.fandom.com/wiki/Module:API_info/flavor/event
local Util = require("Util/Util")

local flavor = {
	mainline = 0x1,
	vanilla = 0x2,
	tbc = 0x4,
}

local m = {}

local sources = {
	api = {
		url = "https://raw.githubusercontent.com/Ketho/BlizzardInterfaceResources/%s/Resources/GlobalAPI.lua",
		cache = "cache/GlobalAPI_%s.lua",
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
		cache = "cache/Events_%s.lua",
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
	"tbc",
}

function m:main()
	for source, info in pairs(sources) do
		local data = self:GetData(source)
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

function m:GetData(sourceType)
	local info = sources[sourceType]
	local parts = {}
	local data = {}
	for _, branch in pairs(branches) do
		local path = info.cache:format(branch)
		Util:CacheFile(path, info.url:format(branch))
		local fileTbl = require(path:gsub("%.lua", ""))
		local location = info.location(fileTbl)
		parts[branch] = info.map(location)
		for name in pairs(parts[branch]) do
			data[name] = true
		end
	end
	for k in pairs(data) do
		local mainline = parts.mainline[k] and flavor.mainline or 0
		local vanilla = parts.vanilla[k] and flavor.vanilla or 0
		local tbc = parts.tbc[k] and flavor.tbc or 0
		data[k] = mainline | vanilla | tbc
	end
	return data
end

m:main()
print("done")
