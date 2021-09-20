local lfs = require "lfs"
local Util = require("Util/Util")
local apidoc = require("Util/apidoc_nontoc")

-- run this script, then FindFrameXmlEvent and then this script again
local framexml_data = loadfile("out/lua/API_info.patch.event_retail_framexml.lua")()

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
		t[name] = t[name] or {}
		if version == "8.0.1" then -- event docs were added in 8.0.1
			t[name][1] = false
		else
			t[name][1] = version
		end
	end
	for name, version in pairs(removed) do
		t[name] = t[name] or {}
		t[name][2] = version
	end
	return t
end

local function GetEventMap(data)
	local t = {}
	for _, info in pairs(data) do
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
		if not Util.RelativePath[folder] then
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
			local docTables = apidoc:LoadBlizzardDocs(path)
			t[version] = GetEventMap(docTables)
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
		if type(tbl[1]) == "string" then
			file:write(string.format('"%s"', tbl[1]))
		elseif tbl[1] == false then
			file:write("false")
			-- file:write(string.format('"%s"', framexml_data[name]))
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
