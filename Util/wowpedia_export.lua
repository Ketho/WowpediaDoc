local gumbo = require "gumbo"
local xml2lua = require "xml2lua"
local handler = require "xmlhandler.tree"
local Util = require("Util/Util")
local m = {}

local export_url = "https://wowpedia.fandom.com/wiki/Special:Export"
local FOLDER = "cache_wowpedia/"
m.OUTPUT_HTML = FOLDER.."export_%s.html"
m.OUTPUT_XML = FOLDER.."export_%s.xml"

-- actually supposed to use mediawiki api
local function get_api_cat_names(catname)
	local path = m.OUTPUT_HTML:format(catname)
	local form = string.format("catname=%s&addcat=Add", catname)
	local res = Util:DownloadFilePost(path, export_url, form, true)
	local document = gumbo.parseFile(path)
	local text = document:getElementById("ooui-php-2").childNodes[1].data
	local names = Util:strsplit(text, "\n")
	table.sort(names)
	return names
end

local function get_api_cat_pages(catName, names)
	local form = string.format("pages=%s&curonly=1", names)
	local res = Util:DownloadFilePost(m.OUTPUT_XML:format(catName), export_url, form, 60)
end

function m:get_api_cat(catName)
	Util:MakeDir(FOLDER)
	local names = get_api_cat_names(catName)
	get_api_cat_pages(catName, table.concat(names, "\n"))
end

-- just a quick single page, no caching
function m:get_api_page(pageName)
	local form = string.format("pages=%s&curonly=1", pageName)
	local body = Util:HttpPostRequest(export_url, form)
	local parser = xml2lua.parser(handler)
	parser:parse(body)
	local page = handler.root.mediawiki.page
	return page.revision.text[1]
end

return m
