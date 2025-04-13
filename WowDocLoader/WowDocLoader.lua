-- WoWDocLoader is only supposed to read Blizzard_APIDocumentation
local lfs = require "lfs"
local Path = require "path"
local Util = require("Util.Util")
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
	local path = Path.join(framexml_path, name)
	local toc_path = Path.join(path, name..".toc")
	local file = io.open(toc_path)
	if not file then
		error(string.format("%s has no TOC file", path))
	end
	for line in file:lines() do
		local fileName = line:match(".-%.lua") -- trim the newline char
		if fileName then
			LoadFile(Path.join(path, fileName))
		end
	end
	file:close()
end

function m:main(branch)
	if APIDocumentation then return end
	Util:LoadLuaEnums(branch)
	require(Path.join(LOADER_PATH, "Compat"))

	local latestFrameXML = Util:GetLatestBuild(branch)
	-- local latestFrameXML = "./wow-ui-source/Interface"
	local addons_path = Path.join(latestFrameXML, "AddOns")
	LoadAddon(addons_path, "Blizzard_APIDocumentation")
	LoadAddon(addons_path, "Blizzard_APIDocumentationGenerated")

	require(Path.join(LOADER_PATH, "TypeDocumentation"))
	-- require(Path.join(WowDocLoader_Path, "MissingDocumentation"))
	-- self:PrintSystems()
end

function m:PrintSystems()
	for k, v in pairs(APIDocumentation.systems) do
		print(k, v.Name)
	end
end

return m
