-- used for https://wowpedia.fandom.com/wiki/Category:API_namespaces
-- see also https://wowpedia.fandom.com/wiki/Template:API_namespaces_subcategory
local m = {}

local HTML_LIST_START = '<ul class="plainlinks elinks">\n'
local HTML_LIST_ITEM = [=[<li style="padding-left: 0px"><span style="display:inline-block; width:20px; text-align:center">[[Image:%s.png|16px|link=]]</span> %s</li>
]=]
local HTML_LIST_END = '</ul>'

local links = {
	{
		icon = "Townlong-Yak_BAD",
		url = "https://www.townlong-yak.com/framexml/live/Blizzard_APIDocumentation/%s",
		linktext = "Blizzard API Docs",
		author = "Townlong Yak",
	},
	{
		icon = "ProfIcons_engineering",
		url = "https://mrbuds.github.io/wow-api-web/?search=api:system:%s",
		linktext = "Offline /api addon",
		author = "MrBuds",
	},
}

local function FormatLink(info, urlParam)
	local url = info.url:format(urlParam)
	local link = string.format("[%s %s] %s", url, info.linktext, info.author)
	return HTML_LIST_ITEM:format(info.icon, link)
end

local function GetElinkText(args)
	local s = HTML_LIST_START
	if args.filename then
		s = s..FormatLink(links[1], args.filename)
	end
	if args.system then
		s = s..FormatLink(links[2], args.system)
	end
	s = s..HTML_LIST_END
	return s
end

function m.main(f)
	return GetElinkText(f.args)
end

return m
