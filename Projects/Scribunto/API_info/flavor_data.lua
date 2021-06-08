-- https://wowpedia.fandom.com/wiki/Module:API_info/flavor_data
local Util = require("Util/Util")

local flavor = {
	live = 0x1,
	classic_era = 0x2,
	bcc = 0x4,
}

local m = {}

local sources = {
	api = {
		url = "https://raw.githubusercontent.com/Ketho/BlizzardInterfaceResources/%s/Resources/GlobalAPI.lua",
		cache = "cache/GlobalAPI_%s.lua",
		out = "out/lua/API_info__api.lua",
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
		out = "out/lua/API_info__event.lua",
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

local branches = {
	"live",
	"classic_era",
	"classic", -- bcc
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
		local live = parts.live[k] and flavor.live or 0
		local classic_era = parts.classic_era[k] and flavor.classic_era or 0
		local bcc = parts.classic[k] and flavor.bcc or 0
		data[k] = live | classic_era | bcc
	end
	return data
end

m:main()
print("done")
