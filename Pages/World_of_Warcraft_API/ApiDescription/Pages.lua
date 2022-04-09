local xml2lua = require "xml2lua"
local handler = require "xmlhandler.tree"
handler = handler:new()
local Util = require("Util/Util")
local wowpedia_export = require("Util/wowpedia_export")
local m = {}

local function GetDescription(text)
	local tag = text:match("<!%-%-desc%-%->(.-)\n")
	if tag then
		return tag
	else
		local t = Util:strsplit(text, "\n")
		return t[2]
	end
end

function m:main()
	local cat = "API+functions"
	wowpedia_export:main(cat)
	local xmlstr = xml2lua.loadFile(wowpedia_export.OUTPUT_XML:format(cat))
	local parser = xml2lua.parser(handler)
	parser:parse(xmlstr)
	local t = {}
	for _, page in pairs(handler.root.mediawiki.page) do
		local name = page.title:match("^API (.+)")
		if name then
			name = name:gsub("^C ", "C_")
			local desc = GetDescription(page.revision.text[1])
			t[name] = desc
			-- print(page.title, desc)
		end
	end
	return t
end

return m
