local util = require "util"

local api_path = "Pages/API/GlobalAPI.lua"
local api_url = "https://raw.githubusercontent.com/Ketho/BlizzardInterfaceResources/live/Resources/GlobalAPI.lua"

util:DownloadFile(api_path, api_url)
local api = require(api_path:gsub("%.lua", ""))
local global_api = util:ToMap(api[1])

local file = io.open("Pages/API/World_of_Warcraft_API.txt", "r")
local newFile = io.open("Pages/API/World_of_Warcraft_API_out.txt", "w")

-- having difficulties getting the plain wikitext from
-- https://wow.gamepedia.com/api.php?action=parse&page=World_of_Warcraft_API&format=json&contentmodel=wikitext
local wowpedia = {}
local tags = {
	SECURE = true,
	NOCOMBAT = true,
	HW = true,
	--UI = true,
	--Lua = true,
}

for line in file:lines() do
	if line:match("^: (.-)") then
		local tag = line:match("^: <small>(.-)</small>")
		local name = line:match("%[%[API (.-)|")
		if name and (not tag or tags[tag]) then
			table.insert(wowpedia, name) -- allow finding duplicates
		end
	elseif line == "== Classic ==" then
		break
	end
end

local function FindDuplicates()
	print("-- duplicates")
	local t = {}
	for _, v in pairs(wowpedia) do
		if t[v] then
			print(v)
		else
			t[v] = true
		end
	end
end
FindDuplicates()

local function FindMissing()
	local wowpedia_map = util:ToMap(wowpedia)
	print("-- missing")
	for k in pairs(global_api) do
		if not wowpedia_map[k] then
			print(k)
		end
	end
	print("-- unneeded")
	for k in pairs(wowpedia_map) do
		if not global_api[k] then
			print(k)
		end
	end
end
FindMissing()

print("done!")
