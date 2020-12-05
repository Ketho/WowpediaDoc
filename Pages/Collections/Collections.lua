-- export to lua tables for in-game use
local parser = require "util/wowtoolsparser"
os.execute("mkdir out\\lua")
local OUT = "out/lua/%s.lua"

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
		fs = '\t[%d] = {"%s", %d, %d},\n',
		func = function(csv)
			local t = {}
			for l in csv:lines() do
				local ID = tonumber(l.ID)
				if ID then
					t[ID] = {l.Name_lang, tonumber(l.Flags), tonumber(l.SourceTypeEnum)}
				end
			end
			return t
		end,
	},
	battlepetspecies = {
		fs = '\t[%d] = {%d, %d, %d},\n',
		func = function(csv)
			local t = {}
			for l in csv:lines() do
				local ID = tonumber(l.ID)
				if ID then
					t[ID] = {tonumber(l.SummonSpellID), tonumber(l.Flags), tonumber(l.SourceTypeEnum)}
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

local function ParseDBC(name)
	local csv = parser.ReadCSV(name, {header=true})
	return handlers[name].func(csv)
end

local function SerializeTable(name)
	local dbc = ParseDBC(name)
	local file = io.open(OUT:format(name), "w")
	file:write(string.format("dbc_%s = {\n", name))
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

print("done")
