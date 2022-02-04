-- exports to lua tables for use in an addon
local Util = require("Util/Util")
local parser = require("Util/wowtoolsparser")
local dbc_patch = require("Projects/DBC/DBC_patch")
local OUTPUT_DBC = "KethoWowpedia/dbc/%s.lua"
local OUTPUT_PATCH = "KethoWowpedia/patch/%s.lua"

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
		fs = '\t[%d] = {%d, %d, %d},\n',
		func = function(csv)
			local t = {}
			for l in csv:lines() do
				local ID = tonumber(l.ID)
				if ID then
					t[ID] = {tonumber(l.SummonSpellID), tonumber(l.SourceTypeEnum), l.Flags}
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
					t[ID] = {tonumber(l.ItemID), tonumber(l.Flags), tonumber(l.SourceTypeEnum)}
				end
			end
			return t
		end,
	},
}

local function ParseDbc(name, options)
	local csv, build = parser:ReadCSV(name, options)
	return handlers[name].func(csv), build
end

local function WriteDbcTable(name, path, options)
	local dbc, build = ParseDbc(name, options)
	local file = io.open(path, "w")
	file:write("-- "..build.."\n")
	file:write(string.format("KethoWowpedia.dbc.%s = {\n", name))
	local fs = handlers[name].fs
	for _, id in pairs(Util:SortTable(dbc)) do
		local v = dbc[id]
		file:write(fs:format(id, table.unpack(v)))
	end
	file:write("}\n")
	file:close()
end

local initialBuilds = {
	mount = "^7.3.0", -- 6.0.1 broken
	battlepetspecies = "^7.3.0", -- 6.0.1 broken
}

local function WritePatchTable(name, path, options)
	options.initial = initialBuilds[name]
	local data = dbc_patch:GetPatchData(name, options)
	local file = io.open(path, "w")
	file:write(string.format("KethoWowpedia.patch.%s = {\n", name))
	local fs = '\t[%d] = "%s",\n'
	for _, id in pairs(Util:SortTable(data)) do
		local version = data[id]:match("^%d+%.%d+%.%d+")
		file:write(fs:format(id, version))
	end
	file:write("}\n")
	file:close()
end

local function main(options)
	options = Util:GetFlavorOptions(options)
	print("-- writing dbc data")
	for name in pairs(handlers) do
		WriteDbcTable(name, OUTPUT_DBC:format(name), options)
	end
	print("-- writing patch data")
	for _, name in pairs({"mount", "battlepetspecies", "toy", "uimap"}) do
		WritePatchTable(name, OUTPUT_PATCH:format(name), options)
	end
end

main() -- ["ptr", "mainline", "classic"]
print("done")
