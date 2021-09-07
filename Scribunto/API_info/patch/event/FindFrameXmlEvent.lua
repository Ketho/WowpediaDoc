local lfs = require "lfs"
local Util = require("Util/Util")
local event_data = loadfile("out/lua/API_info.patch.event_retail.lua")()

local skipDir = {
	["."] = true,
	[".."] = true,
}

local m = {}

function m:IterateFiles(folder, search)
	for fileName in lfs.dir(folder) do
		local path = folder.."/"..fileName
		local attr = lfs.attributes(path)
		if attr.mode == "directory" then
			if not skipDir[fileName] then
				local path2 = self:IterateFiles(path, search)
				if path2 then
					return path2
				end
			end
		else
			if fileName:find("%.lua") and fileName ~= "GlobalStrings.lua" then
				if self:ParseLua(path, search) then
					return path
				end
			end
		end
	end
end

function m:ParseLua(path, search)
	local file = io.open(path, "r")
	local text = file:read("a")
	return text:find(search)
end

function m:FindEvent(event)
	local path = self:IterateFiles("FrameXML/retail", event)
	return path
end

function m:GetEvents()
	for _, event in pairs(Util:SortTable(event_data)) do
		local v = event_data[event]
		if v[1] == false then
			local path = self:FindEvent(event)
			print(event, (path:gsub("FrameXML/retail/", "")))
		end
	end
end

function m:main()
	-- print(self:FindEvent("UNIT_SPELL_HASTE"))
	self:GetEvents()
end

m:main()
print("done")
