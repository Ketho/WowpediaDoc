local lfs = require("lfs")
local pathlib = require("path")

local log = require("util.log")
local lua_enum = require("WowDocLoader.LuaEnum")

local m = {}
local LOADER_PATH = "WowDocLoader"

local function LoadFile(path)
	local attr = lfs.attributes(path)
	if not attr then
		error("path not found: "..path)
	end

	local file = loadfile(path)
	if not file then
		error("could not load path: "..path)
	end
	file()
end

local function LoadAddon(framexml_path, name)
	local path = pathlib.join(framexml_path, name)
	local toc_path = pathlib.join(path, name..".toc")
	local file = io.open(toc_path)
	if not file then
		error(string.format("%s has no TOC file", path))
	end
	for line in file:lines() do
		local fileName = line:match(".-%.lua") -- trim the newline char
		if fileName then
			LoadFile(pathlib.join(path, fileName))
		end
	end
	file:close()
end

function m:main(branch)
	if APIDocumentation then
		log:warn("WoWDocLoader: APIDocumentation already loaded")
		return
	end
	lua_enum:LoadLuaEnums(branch)
	require(pathlib.join(LOADER_PATH, "compat"))

	local addons_path = pathlib.join("wow-ui-source", "Interface", "AddOns")
	LoadAddon(addons_path, "Blizzard_APIDocumentation")
	LoadAddon(addons_path, "Blizzard_APIDocumentationGenerated")

	require(pathlib.join(LOADER_PATH, "TypeDocumentation"))
	-- require(Path.join(WowDocLoader_Path, "MissingDocumentation"))
	-- self:PrintSystems()
end

function m:PrintSystems()
	for k, v in pairs(APIDocumentation.systems) do
		print(k, v.Name)
	end
end

return m
