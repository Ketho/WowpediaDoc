-- first strip out UTF8 BOM from files with powershell
local lfs = require "lfs"

local FRAMEXML_PATH = "D:/Dev/Repo/wow-dev/#FrameXML/wow-ui-source gethe"

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
	GuildBankTabPermissionsTabTemplate = true, 	-- commented out
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
	for _, folder in pairs(folders) do
		m:IterateFiles(FRAMEXML_PATH.."/"..folder)
	end
	if not lfs.attributes("out") then
		lfs.mkdir("out")
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
					if virtual == "true" then -- attribute value for IMECandidatesFrame is "false"
						-- misses `parentKey` attributes instead of `name`
						-- and when not everything is on 1 line e.g. SecureHandlerDragTemplate
						local objectType = line:match('<(.-) ')
						-- OrderHallTalentFrameTick doesnt have `name` as the first attribute
						local name = line:match(' name%s?="(.-)"')
						if not name and fileName == "SecureHandlerTemplates.xml" then
							line = lookbackLines[lineIdx-2]..lookbackLines[lineIdx-1]..line
							objectType, name = line:match('<(.-) name%s?="(.-)"')
						end
						if name and not filterTemplates[name] then
							dataTypes.template.data[name] = {
								name = name,
								object = objectType,
								inherits = self:FindAttribute(line, "inherits"),
								mixin = mixin,
							}
						end
					end
					lookbackLines[lineIdx] = line
				end
			elseif fileName:find("%.lua") then
				local file = io.open(path, "r")
				for line in file:lines() do
					for word, pattern in pairs(mixinFunc) do
						local attrValue = line:match(pattern)
						if attrValue and not filterMixinArgs[attrValue] then
							self:HandleCommaString(dataTypes.mixin.data, attrValue)
						end
					end
				end
			end
		end
	end
end

function m:FindAttribute(line, attrName)
	local pattern = attrName..'%s?="(.-)"'
	local attrValue = line:match(pattern)
	if attrValue then
		return attrValue
	end
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
	local file = io.open("out/"..info.label..".lua", "w")
	file:write(string.format("local %s = {\n", info.label))
	for _, key in pairs(SortTable(info.data)) do
		local value = info.data[key]
		local text = info.tostring(value)
		file:write(text.."\n")
	end
	file:write(string.format("}\n\nreturn %s\n", info.label))
end

m:main()
print("Done")
