local xml = require "xml"
local Util = require("Util/Util")
Util:MakeDir("cache_lua")

local OUTPUT = "cache_lua/World_of_Warcraft_API.xml"
local m = {}

function m:SaveExport()
	local url = "https://wowpedia.fandom.com/wiki/Special:Export"
	local requestBody = "pages=World_of_Warcraft_API&curonly=1"
	Util:DownloadFilePost(OUTPUT, url, requestBody)
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
	local file = io.open(OUTPUT)
	local text = file:read("a")
	file:close()
	local xml_data = xml.load(text)
	text = xml_data[2][4][8][1]
	text = self:ReplaceHtml(text)
	if isRetail then
		local str_start = text:find("== API Reference ==")
		local str_end = text:find("== Classic ==")
		return text:sub(str_start, str_end-1)
	else
		return text
	end
end

return m
