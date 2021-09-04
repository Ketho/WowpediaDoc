-- first strip out UTF8 BOM from files with powershell
local lfs = require "lfs"

-- too lazy to parse FrameXML_TBC.toc or whatever the new file loading structure is
local flavors = {
	retail = "../#FrameXML/Generate-Globals/wow-ui-source/Interface",
	classic = "../#FrameXML/Generate-Globals/wow-ui-source/Interface_TBC",
}
local OUT_PATH = "../BlizzardInterfaceResources/Resources"

local folders = {
	"AddOns",
	"FrameXML",
	"SharedXML",
}

local skipDir = {
	["."] = true,
	[".."] = true,
}

local dataTypes = {
	mixin = {
		label = "Mixins",
		data = {},
		tostring = function(name)
			return string.format('\t"%s",', name)
		end,
	},
	template = {
		label = "Templates",
		data = {},
		tostring = function(tbl)
			local s = string.format('\t["%s"] = {type = "%s"', tbl.name, tbl.object)
			if tbl.mixin then
				s = s..string.format(', mixin = "%s"', tbl.mixin)
			end
			if tbl.inherits then
				s = s..string.format(', inherits = "%s"', tbl.inherits)
			end
			if tbl.intrinsic then
				s = s..string.format(', intrinsic = true', tbl.inherits)
			end
			s = s.."},"
			return s
		end,
	},
}

local mixinFunc = {
	CreateFromMixins = "CreateFromMixins%((.-)%)",
	CreateAndInitFromMixin = "CreateAndInitFromMixin%((.-)[,%)]", -- 9 mixins
}

local filterMixinArgs = {
	[""] = true, -- no args
	["..."] = true, -- definition
	["baseModule or DEFAULT_OBJECTIVE_TRACKER_MODULE"] = true,
	["dataProvider"] = true,
	["mixin"] = true,
	["nodeMixin"] = true,
	["self"] = true,
	["subSystemMixin"] = true,
}

local filterTemplates = {
	-- AddOns\Blizzard_GuildControlUI\Blizzard_GuildControlUI.xml
	GuildBankTabPermissionsTabTemplate = true, -- commented out
}

local function SortTable(tbl)
	local t = {}
	for k in pairs(tbl) do
		table.insert(t, k)
	end
	table.sort(t, function(a, b)
		return a:lower() < b:lower()
	end)
	return t
end

local m = {}

function m:main()
	for _, flavor in pairs(flavors) do
		for _, folder in pairs(folders) do
			m:IterateFiles(flavor.."/"..folder)
		end
	end
	for _, info in pairs(dataTypes) do
		self:WriteDataFile(info)
	end
end

function m:IterateFiles(folder)
	for fileName in lfs.dir(folder) do
		local path = folder.."/"..fileName
		local attr = lfs.attributes(path)
		if attr.mode == "directory" then
			if not skipDir[fileName] then
				self:IterateFiles(path)
			end
		else
			if fileName:find("%.xml") then
				self:ParseXml(path, fileName)
			elseif fileName:find("%.lua") then
				self:ParseLua(path)
			end
		end
	end
end

function m:ParseXml(path, fileName)
	-- could use xml2lua for less dumb parsing
	local file = io.open(path, "r")
	local lookbackLines, lineIdx = {}, 0
	for line in file:lines() do
		lineIdx = lineIdx + 1
		local mixin = self:FindAttribute(line, "mixin")
		if mixin then
			self:HandleCommaString(dataTypes.mixin.data, mixin)
		end
		local virtual = self:FindAttribute(line, "virtual")
		local intrinsic = self:FindAttribute(line, "intrinsic")
		if virtual == "true" or intrinsic then -- attribute value for IMECandidatesFrame is "false"
			local objectType = line:match('<(.-) ')
			local name = line:match(' name%s?="(.-)"')
			if not name and fileName == "SecureHandlerTemplates.xml" then
				-- not everything is on 1 line e.g. SecureHandlerDragTemplate
				line = lookbackLines[lineIdx-2]..lookbackLines[lineIdx-1]..line
				objectType, name = line:match('<(.-) name%s?="(.-)"')
			end
			if name and not filterTemplates[name] and not name:find("%$") then
				dataTypes.template.data[name] = {
					name = name,
					object = objectType,
					inherits = self:FindAttribute(line, "inherits"),
					mixin = mixin,
					intrinsic = intrinsic,
				}
			end
		end
		lookbackLines[lineIdx] = line
	end
	file:close()
end

function m:ParseLua(path)
	local file = io.open(path, "r")
	for line in file:lines() do
		for _, pattern in pairs(mixinFunc) do
			local attrValue = line:match(pattern)
			if attrValue and not filterMixinArgs[attrValue] then
				self:HandleCommaString(dataTypes.mixin.data, attrValue)
			end
		end
	end
	file:close()
end

function m:FindAttribute(line, name)
	local pattern = name..'%s?="(.-)"'
	return line:match(pattern)
end

function m:HandleCommaString(tbl, str)
	if str:find(",") then
		for part in str:gmatch("[^%s,]+") do
			tbl[part] = part
		end
	else
		tbl[str] = str
	end
end

function m:WriteDataFile(info)
	local file = io.open(OUT_PATH.."/"..info.label..".lua", "w")
	file:write(string.format("local %s = {\n", info.label))
	for _, key in pairs(SortTable(info.data)) do
		local value = info.data[key]
		local text = info.tostring(value)
		file:write(text.."\n")
	end
	file:write(string.format("}\n\nreturn %s\n", info.label))
	file:close()
end

m:main()
print("Done")
