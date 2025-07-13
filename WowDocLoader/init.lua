local lfs = require("lfs")
local pathlib = require("path")

local log = require("util.log")
local products = require("WowDocLoader.products")
local git = require("WowDocLoader.git")
local enum = require("WowDocLoader.enum")

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

local function ProductToBranch(product)
	local framexml = products.gethe_branch[product]
	local blizzres = products.blizzres_branch[product]
	if product and #product > 0 then
		log:success(string.format("TACT product: %s", product))
	end
	if framexml and #framexml > 0 then
		log:success(string.format("Gethe branch: %s", framexml))
	end
	if blizzres and #blizzres > 0 then
		log:success(string.format("BlizzRes branch: %s", blizzres))
	end
	return framexml, blizzres
end

function m:main(product)
	if APIDocumentation then
		log:warn("WoWDocLoader: APIDocumentation already loaded")
		return
	end
	local framexml_branch, blizzres_branch = ProductToBranch(product)
	git:pull("https://github.com/Gethe/wow-ui-source", framexml_branch)
	enum:LoadLuaEnums(blizzres_branch)
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
