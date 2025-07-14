local xml2lua = require "xml2lua"
local handler = require "xmlhandler.tree"
local util = require("util")
util:MakeDir("cache_lua")

local OUTPUT = "cache_lua/World_of_Warcraft_API.xml"
local m = {}

function m:SaveExport()
	local url = "https://warcraft.wiki.gg/wiki/Special:Export"
	local requestBody = "pages=World_of_Warcraft_API&curonly=1"
	util:DownloadFilePost(url, OUTPUT, requestBody, 60)
end

local symbols = {
	["&lt;"] = "<",
	["&gt;"] = ">",
	["&amp;"] = "&",
}

function m:ReplaceHtml(text)
	return text:gsub("&.-;", symbols)
end

function m:GetWikitext(isRetail)
	local xmlstr = xml2lua.loadFile(OUTPUT)
	local parser = xml2lua.parser(handler)
	parser:parse(xmlstr)
	local text = handler.root.mediawiki.page.revision.text[1]
	text = self:ReplaceHtml(text)
	return text
end

return m
