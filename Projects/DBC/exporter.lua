-- export to lua tables for in-game use
local parser = require("Util/wowtoolsparser")
local Util = require("Util/Util")
local output = "KethoWowpedia/dbc/%s.lua"

Util:MakeDir("KethoWowpedia/dbc")

local handlers = {
	creaturemodeldata = {
		fs = '\t[%d] = %d,\n',
		func = function(csv)
			local t = {}
			for l in csv:lines() do
				local ID = tonumber(l.ID)
				if ID then
					t[ID] = {tonumber(l.FileDataID)}
				end
			end
			return t
		end,
	},
	creaturedisplayinfo = {
		fs = '\t[%d] = %d,\n',
		func = function(csv)
			local t = {}
			for l in csv:lines() do
				local ID = tonumber(l.ID)
				if ID then
					t[ID] = {tonumber(l.ModelID)}
				end
			end
			return t
		end,
	},
	mount = {
		fs = '\t[%d] = %d, -- %s\n',
		func = function(csv)
			local t = {}
			for l in csv:lines() do
				local ID = tonumber(l.ID)
				if ID then
					t[ID] = {tonumber(l.Flags), l.Name_lang}
				end
			end
			return t
		end,
	},
	battlepetspecies = {
		fs = '\t[%d] = %d,\n',
		func = function(csv)
			local t = {}
			for l in csv:lines() do
				local ID = tonumber(l.ID)
				if ID then
					t[ID] = {tonumber(l.SummonSpellID)}
				end
			end
			return t
		end,
	},
	toy = {
		fs = '\t[%d] = {%d, %d, %d},\n',
		func = function(csv)
			local t = {}
			for l in csv:lines() do
				local ID = tonumber(l.ID)
				if ID then
					t[tonumber(l.ItemID)] = {ID, tonumber(l.Flags), tonumber(l.SourceTypeEnum)}
				end
			end
			return t
		end,
	},
}

local function ParseDBC(name, BUILD)
	local csv, build = parser.ReadCSV(name, {header=true, build = BUILD})
	return handlers[name].func(csv), build
end

local function SerializeTable(name, BUILD)
	local dbc, build = ParseDBC(name, BUILD)
	local file = io.open(output:format(name), "w")
	file:write("-- "..build.."\n")
	file:write(string.format("KethoWowpedia.dbc.%s = {\n", name))
	local fs = handlers[name].fs
	for id, v in pairs(dbc) do
		file:write(fs:format(id, table.unpack(v)))
	end
	file:write("}\n")
	file:close()
end

for name in pairs(handlers) do
	SerializeTable(name)
end
