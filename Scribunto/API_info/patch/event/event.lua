local lfs = require "lfs"
local Util = require("Util/Util")

local flavors = {
	retail = {
		id = "retail",
		input = "FrameXML/retail",
		out = "out/lua/API_info.patch.event_retail.lua",
	},
	classic = {
		id = "classic",
		input = "FrameXML/classic",
		out = "out/lua/API_info.patch.event_classic.lua",
	},
}

local ApiCache = {}
APIDocumentation = {}
Enum = {
	PlayerCurrencyFlagsDbFlags = {
		InBackpack = 0,
		UnusedInUI = 0,
	},
}

function APIDocumentation:AddDocumentationTable(info)
	table.insert(ApiCache, info)
end

-- this time I dont really want to load Blizzard_APIDocumentation.toc
local nondoc = {
	["."] = true,
	[".."] = true,
	["Blizzard_APIDocumentation.lua"] = true,
	["EventsAPIMixin.lua"] = true,
	["FieldsAPIMixin.lua"] = true,
	["FunctionsAPIMixin.lua"] = true,
	["SystemsAPIMixin.lua"] = true,
	["TablesAPIMixin.lua"] = true,
}

local pre252_format = {
	["1.13.2"] = true,
	["1.13.3"] = true,
	["1.13.4"] = true,
	["1.13.5"] = true,
	["1.13.6"] = true,
	["1.13.7"] = true,
	["2.5.1"] = true,
}

local m = {}

function m:GetPatchData(tbl)
	local added, removed = {}, {}
	for _, version in pairs(Util:SortTable(tbl)) do
		local v = tbl[version]
		for name in pairs(v) do
			if not added[name] then
				added[name] = version
			end
		end
		for name in pairs(added) do
			if not v[name] and not removed[name] then
				removed[name] = version
			end
		end
	end

	local t = {}
	for name, version in pairs(added) do
		if version == "8.0.1" then -- event docs were added in 8.0.1
			added[name] = nil
		else
			t[name] = t[name] or {}
			t[name][1] = version
		end
	end
	for name, version in pairs(removed) do
		t[name] = t[name] or {}
		t[name][2] = version
	end
	return t
end

local function GetEventMap()
	local t = {}
	for _, info in pairs(ApiCache) do
		if info.Events then
			for _, event in pairs(info.Events) do
				t[event.LiteralName] = true
			end
		end
	end
	return t
end

function m:GetFrameXmlData(info)
	local t = {}
	for folder in lfs.dir(info.input) do
		if not nondoc[folder] then
			local version = folder:match("%d+%.%d+.%d+")
			local path
			if info.id == "retail" then
				path = info.input.."/"..folder.."/Blizzard_APIDocumentation"
			elseif info.id == "classic" then
				if pre252_format[version] then
					path = info.input.."/"..folder.."/AddOns/Blizzard_APIDocumentation"
				else
					path = info.input.."/"..folder.."/Interface/AddOns/Blizzard_APIDocumentation"
				end
			end
			for fileName in lfs.dir(path) do
				if not nondoc[fileName] and fileName:find("%.lua") then
					loadfile(path.."/"..fileName)()
				end
			end
			t[version] = GetEventMap()
			for k in pairs(ApiCache) do
				ApiCache[k] = nil
			end
		end
	end
	return t
end

function m:WritePatchData(info)
	local frameXML = self:GetFrameXmlData(info)
	local patchData = self:GetPatchData(frameXML)
	local file = io.open(info.out, "w")
	file:write("local data = {\n")
	for _, name in pairs(Util:SortTable(patchData)) do
		local tbl = patchData[name]
		file:write(string.format('\t["%s"] = {', name))
		if tbl[1] then
			file:write(string.format('"%s"', tbl[1]))
		else
			file:write("nil")
		end
		if tbl[2] then
			file:write(string.format(', "%s"', tbl[2]))
		end
		file:write("},\n")
	end
	file:write("}\n\nreturn data\n")
	file:close()
end

function m:main()
	self:WritePatchData(flavors.retail)
	self:WritePatchData(flavors.classic)
end

m:main()
print("done")
