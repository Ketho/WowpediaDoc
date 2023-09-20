local data = mw.loadData("Module:API_info/navbox/data")
local cvar_module = require("Module:API_info/cvar")
local m = {}

local meta = {
	guide = {
		label = "Guide",
	},
	api = {
		label = "Global API",
		link = "API %s",
	},
	api2 = {
		label = "Test",
		link = "API %s",
	},
	framexml = {
		label = "FrameXML",
		url = "https://github.com/Gethe/wow-ui-source/search?q=%s",
	},
	widget = {
		label = "Widget API",
		link = "API %s %s",
		linkfunc = function(name, link)
			local widget, method = name:match("(%a+):(%a+)")
			return link:format(widget, method)
		end,
	},
	script = {
		label = "Scripts",
		link = "UIHANDLER %s",
	},
	event = {
		label = "Events",
	},
	cvar = {
		label = "CVars",
		link = "CVar %s",
		ttfunc = function(name)
			return cvar_module.GetTooltip(name)
		end,
	},
	macro = {
		label = "Macros", -- Macro commands
		link = "MACRO %s",
	},
	uitech = {
		label = "Docs",
	},
	howto = {
		label = "Tutorials",
	}
}

local order = {
	"guide",
	"api",
	"api2",
	"framexml",
	"widget",
	"script",
	"event",
	"cvar",
	"macro",
	"uitech",
	"howto",
}

local function FormatLink(info, name, systemInfo)
	local link
	if info.url then
		local githubSearch = name:match("%.(%w+)") or name
		link = string.format("[%s %s]", info.url:format(githubSearch), name)
	else
		local page
		if info.linkfunc then
			page = info.linkfunc(name, info.link)
		else
			page = string.format(info.link or "%s", name)
		end
		link = string.format("[[%s|%s]]", page, name:match("%.(%w+)") or name)
		-- if name:find("%.") and not systemInfo.showNamespace then
		-- 	link = string.format(".[[%s|%s]]", page, name:match("%.(%w+)"))
		-- else
		-- 	link = string.format("[[%s|%s]]", page, name)
		-- end
		if info.ttfunc then
			link = info.ttfunc(name) or name
		end
	end
	return link
end

local showEmptyHeader, evenodd

local function GetChildNavbox(f, systemInfo, apiType)
	local meta_info = meta[apiType]
	local cat_info = systemInfo[apiType]
	local template = {
		title = "Navbox",
		args = {
			"child",
			state = "uncollapsed",
			above = cat_info.above,
			abovestyle = "text-align: left",
			liststyle = "text-align: left",
			groupwidth = "8em", -- this is actually a min-width
			evenodd = evenodd and "swap" or nil, -- false disables striping
		}
	}
	if systemInfo.hasCategories then
		local t = {}
		for cat_idx, cat_item in ipairs(cat_info) do
			if type(cat_item) == "table" then
				showEmptyHeader = true
				local r = {}
				for _, item in ipairs(cat_item) do
					table.insert(r, "* "..FormatLink(meta_info, item, systemInfo))
				end
				template.args["group"..cat_idx] = cat_item.category or "&nbsp;"
				template.args["list"..cat_idx] = table.concat(r, "\n")
			elseif type(cat_item) == "string" then
				table.insert(t, "* "..FormatLink(meta_info, cat_item, systemInfo))
			end
		end
		if next(t) then
			evenodd = not evenodd -- add contrast manually since they are multiple one-line childboxes
			if showEmptyHeader then
				template.args.title = "&nbsp;"
				showEmptyHeader = false
			end
			template.args.group1 = meta_info.label
			template.args.list1 = table.concat(t, "\n")
		else
			template.args.title = cat_info.label or meta_info.label
		end
	else
		local t = {}
		for cat_idx, cat_item in ipairs(cat_info) do
			table.insert(t, "* "..FormatLink(meta_info, cat_item))
		end
		template.args.group1 = meta_info.label
		template.args.list1 = table.concat(t, "\n")
	end
	return f:expandTemplate(template)
end

-- https://wowpedia.fandom.com/wiki/Template:Navbox
-- https://en.wikipedia.org/wiki/Template:Navbox
local function GetNavbox(f, systemInfo, systemName)
	local template = {
		title = "Navbox",
		args = {
			title = systemInfo.label or systemName,
			state = systemInfo.state or systemInfo.hasCategories and "collapsed" or "uncollapsed",
			navbar = "plain", -- hide V • T • E links
			listclass = "hlist", -- render lists horizontally
		}
	}
	for metaIdx, apiType in pairs(order) do
		if systemInfo[apiType] then
			template.args["list"..metaIdx] = GetChildNavbox(f, systemInfo, apiType)
		end
	end
	return f:expandTemplate(template)
end

function m.main(f)
	local systemName = f.args[1]
	local systemInfo = data[systemName]
	return "\n\n"..GetNavbox(f, systemInfo, systemName)
end

return m
