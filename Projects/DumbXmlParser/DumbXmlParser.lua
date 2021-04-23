-- first strip out UTF8 BOM from files with powershell
local lfs = require "lfs"

local FRAMEXML_PATH = "FrameXML"

local folders = {
	"AddOns",
	"FrameXML",
	"SharedXML",
}

local skipDir = {
	["."] = true,
	[".."] = true,
}

local searchTbl = {
	mixin = {},
	inherits = {},
}

local outputName = {
	mixin = "Mixins",
	inherits = "Templates",
}

local mixinFunc = {
	CreateFromMixins = "CreateFromMixins%((.-)%)",
	CreateAndInitFromMixin = "CreateAndInitFromMixin%((.-)[,%)]", -- 9 mixins
}

local filterMixinArg = {
	[""] = true, -- no args
	["..."] = true, -- definition
	["baseModule or DEFAULT_OBJECTIVE_TRACKER_MODULE"] = true,
	["dataProvider"] = true,
	["mixin"] = true,
	["nodeMixin"] = true,
	["self"] = true,
	["subSystemMixin"] = true,
}

local function SortTable(tbl)
	local t = {}
	for k in pairs(tbl) do
		table.insert(t, k)
	end
	table.sort(t)
	return t
end

local m = {}

function m:main()
	for _, folder in pairs(folders) do
		m:IterateFiles("FrameXML/"..folder)
	end

	local fs = '\t"%s",\n'
	if not lfs.attributes("out") then
		lfs.mkdir("out")
	end
	for keyword, tbl in pairs(searchTbl) do
		local name = outputName[keyword]
		local file = io.open("out/"..name..".lua", "w")
		file:write(string.format("local %s = {\n", name))
		for _, v in pairs(SortTable(tbl)) do
			file:write(fs:format(v))
		end
		file:write(string.format("}\n\nreturn %s\n", name))
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
				-- could use xml2lua for less dumb parsing but for now this will do
				local file = io.open(path, "r")
				for line in file:lines() do
					for word, tbl in pairs(searchTbl) do
						self:FindAttribute(tbl, line, word)
					end
				end
			elseif fileName:find("%.lua") then
				local file = io.open(path, "r")
				for line in file:lines() do
					for word, pattern in pairs(mixinFunc) do
						-- there definitely is a better way to do this
						-- need to request an audience with the Lua gods
						local attrValue = line:match(pattern)
						if attrValue and not filterMixinArg[attrValue] then
							self:HandleCommaString(searchTbl.mixin, attrValue)
						end
					end
				end
			end
		end
	end
end

function m:FindAttribute(tbl, line, attrName)
	-- CharacterModelFrameMixin the only one with a space
	local pattern = attrName..'%s?="(.-)"'
	local attrValue = line:match(pattern)
	if attrValue then
		self:HandleCommaString(tbl, attrValue)
	end
end

function m:HandleCommaString(tbl, str)
	if str:find(",") then
		for s in str:gmatch("[^%s,]+") do
			tbl[s] = true
		end
	else
		tbl[str] = true
	end
end

m:main()
print("Done")
