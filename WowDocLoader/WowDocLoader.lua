-- WoWDocLoader is only supposed to read Blizzard_APIDocumentation
local lfs = require "lfs"
local Path = require "path"
local Util = require("Util.Util")
local m = {}

local LOADER_PATH = "WowDocLoader"

local function LoadFile(path)
	if lfs.attributes(path) then
		local file = loadfile(path)
		file()
	end
end

local function LoadAddon(framexml_path, name)
	local path = Path.join(framexml_path, name)
	local toc_path = Path.join(path, name..".toc")
	print("opening", toc_path)
	local file = io.open(toc_path)
	if not file then
		error(string.format("%s has no TOC file", path))
	end
	for line in file:lines() do
		if line:find("%.lua") then
			LoadFile(Path.join(path, line))
		end
	end
	file:close()
end

function m:main(branch)
	Util:LoadLuaEnums(branch)
	require(Path.join(LOADER_PATH, "Compat"))

	local latestFrameXML = Util:GetLatestBuild(branch)
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
