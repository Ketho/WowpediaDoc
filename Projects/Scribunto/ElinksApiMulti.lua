--local elinksapi = require("Module:Elinks-api")
local m = {}

local HTML_LIST_START = '<ul class="plainlinks elinks" style="list-style-position:outside">\n'
local HTML_LIST_ITEM = [=[<li style="padding-left: 0px"><span style="display:inline-block; width:20px; text-align:center">[[Image:%s.png|16px|link=]]</span> %s</li>
]=]
local HTML_LIST_END = '</ul>'

local wowapiwebType = {
	a = "function",
	e = "event",
}

local links = {
	{
		id = "gh_framexml",
		icon = "GitHub_Octocat",
		url = "https://github.com/Gethe/wow-ui-source/search?q=%s",
		linktext = "GitHub FrameXML",
		author = "Gethe",
	},
	{
		id = "tly_globewut",
		icon = "Townlong-Yak_Globe",
		url = "https://www.townlong-yak.com/globe/wut/#q:%s",
		linktext = "Globe \"wut?\" Tool",
		author = "Townlong Yak",
	},
	{
		id = "tly_apidocs",
		icon = "Townlong-Yak_BAD",
		url = "https://www.townlong-yak.com/framexml/latest/Blizzard_APIDocumentation#%s",
		linktext = "Blizzard API Docs",
		author = "Townlong Yak",
		blizzard_apidoc = true,
	},
	{
		id = "gh_wowapiweb",
		icon = "ProfIcons_engineering",
		url = "https://mrbuds.github.io/wow-api-web/?search=%s",
		linktext = "Offline /api addon",
		author = "MrBuds",
		blizzard_apidoc = true,
	},
}

-- could have just asked for the non-literal event name
local function ConvertEventLiteralName(event)
	local titleCase = ""
	for s in string.gmatch(event:lower(), "%a+") do
		titleCase = titleCase..s:gsub("^%a", string.upper)
	end
	return titleCase
end

-- omit namespace in headers
local function GetApiBaseName(v)
	if v:find("%.") then
		v = v:match(".-%.(.+)")
	end
	return v
end

local function GetSearchParams(args, linkInfo, name)
	local search
	-- github does not do exact searches with dots
	if linkInfo.id == "gh_framexml" then
		search = GetApiBaseName(name)
	elseif linkInfo.id == "gh_wowapiweb" then
		local apiName
		if args.t == "a" then
			apiName = GetApiBaseName(name)
		elseif args.t == "e" then
			apiName = ConvertEventLiteralName(name)
		end
		search = string.format("api:%s:%s:%s", wowapiwebType[args.t], apiName, args.system)
	else
		search = name
	end
	return search
end

local function GetElinkText(args, name)
	local s = HTML_LIST_START
	for _, info in pairs(links) do
		if not args.nodoc or not info.blizzard_apidoc then
			local search = GetSearchParams(args, info, name)
			local url = info.url:format(search)
			local link = string.format("[%s %s] %s", url, info.linktext, info.author)
			s = s..HTML_LIST_ITEM:format(info.icon, link)
		end
	end
	s = s..HTML_LIST_END
	return s
	--local testArgs = {"C_Item.DoesItemExist", "a", nil, nil, nil, ""}}
	--return elinksapi.GetLinks(testArgs)
end

local function GetMultiList(args)
	local s = "{|\n|- style=\"color:#4ec9b0\"\n"
	for _, v in ipairs(args) do
		local header = GetApiBaseName(v)
		s = s..string.format("! align=\"left\" | %s\n", header)
	end
	s = s.."|-\n"
	for _, v in ipairs(args) do
		s = s..string.format("| %s\n", GetElinkText(args, v))
	end
	s = s.."|}"
	return s
end

function m.main(f)
	return GetMultiList(f.args)
end

return m
