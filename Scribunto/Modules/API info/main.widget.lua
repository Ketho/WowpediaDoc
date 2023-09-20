local infobox_module = require("Module:API_info/util/infobox")
local widget_data = mw.loadData("Module:API_info/main/widget/data")
local group_data_module = require("Module:API_info/util/group data")

local INFOBOX_STYLE = '<div class="nomobile" style="float:right; clear:right;">\n%s\n</div>'

local template = {
	title = "api ambox",
	args = {
		border = "red",
		image = "Spell_arcane_portalstormwind",
		size = 72,
		format = "normal",
		info = "<font size=3>See [[Forum:Vote to Leave Fandom]].</font>",
		"<font size=3>'''The API docs will be forked to possibly [https://wiki.gg/ wiki.gg]'''</font>",
	}
}

-- cannot use # operator on mw.loadData tables
local function GetTableSize(tbl)
	local size = 0
	for _ in pairs(tbl) do
		size = size + 1
	end
	return size
end

local function GetFullName(widget, method)
	return string.format("%s:%s", widget, method)
end

local function FormatWowprogLink(widget, method)
	return string.format("widgets/%s/%s.html", widget, method)
end

local links = {
	{
		icon = "GitHub_Octocat.png",
		text = "FrameXML",
		link = function(info)
			if info.apiType == "widget" then
				if widget_data.blizzard.widget[info.widget] then
					return string.format("https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/%s", widget_data.blizzard.widget[info.widget])
				end
			elseif info.apiType == "method" or info.apiType == "script" then
				 return string.format("https://github.com/search?q=repo:Gethe/wow-ui-source+%s&type=code", info.method or info.script)
			end
		end,
	},
	{
		icon = "Wowprogramming.png",
		text = "Wowprogramming",
		link = function(info)
			local wowprog = widget_data.wowprog[info.apiType]
			local key
			if info.apiType == "widget" then
				key = wowprog[info.widget]
			elseif info.apiType == "method" then
				local fullName = info.widget..":"..info.method
				key = wowprog[fullName]
				if not key and widget_data.wowprog_html[fullName] then
					key = FormatWowprogLink(info.widget, info.method)
				end
			elseif info.apiType == "script" and wowprog[info.script] then
				key = wowprog[info.script]
			end
			if key then
				return string.format("https://wowprogramming.com/docs/%s", key)
			end
		end,
	},
}

local function FormatIcon(item)
	item.iconsize = item.iconsize or 16
	local fs = "[[File:%s|%dpx|link=%s]]"
	return fs:format(item.icon, item.iconsize, item.url)
end

local function GetElinkIcons(data)
	local t = {}
	for _, item in pairs(data) do
		table.insert(t, FormatIcon(item))
	end
	return table.concat(t, " &nbsp;")
end

local function FormatCodeOrLink(name)
	local firstChar = name:sub(1, 1)
	local text
	if firstChar == "#" then
		name = name:sub(2)
		text = name:gsub(" ", ":")
	elseif name:find("UIHANDLER ") then
		local widget = name:match("UIHANDLER (%w+)")
		text = string.format("[[UIHANDLER %s|%s]]", widget, widget)
	else
		local widget, method = name:match("(%w+) (%w+)")
		text = string.format("[[API %s|%s:%s]]", name, widget, method)
	end
	return string.format("<code>%s</code>", text)
end

local function GetLinks(info)
	if type(info) ~= "table" then -- hack
		local t = {}
		if info:find("UIHANDLER") then
			t = {apiType = "script", script = info:match("UIHANDLER (%w+)")}
		else
			local widget, method = info:match("(%w+) (%w+)")
			t = {apiType = "method", widget = widget, method = method}
		end
		info = t
	end
	local t = {}
	for _, v in pairs(links) do
		local url = v.link(info)
		if url then
			table.insert(t, {
				id = v.id,
				icon = v.icon,
				text = v.text,
				url = url,
			})
		end
	end
	return t
end

local m = {}

function m:GetInfobox(info)
	local source = {
		"! Links",
		GetLinks(info),
	}
	if next(source[2]) then
		return infobox_module:main(source)
	end
end

local function GetGroupInfoboxItem(t, group, info)
	for _, prefixName in pairs(group) do
		local name = group_data_module:GetNonPrefixName(prefixName)
		table.insert(t, "\n|-\n| ")
		local icons = GetElinkIcons(GetLinks(name))
		table.insert(t, string.format("%s || ", icons or ""))
		local api_text = FormatCodeOrLink(prefixName)
		if name == info.strippedName and GetTableSize(group) > 2 then
			api_text = string.format('<font color="#dda0dd">%s</font>', api_text)
		end
		table.insert(t, string.format("%s || ", api_text))
	end
end

function m:GetGroupInfobox(info)
	local key
	if info.apiType == "method" then
		key = info.widget.." "..info.method
	elseif info.apiType == "script" then
		key = "UIHANDLER "..info.script
	end
	local group = group_data_module.data[key]
	local t = {}
	table.insert(t, '{| class="darktable" cellpadding=2')
	GetGroupInfoboxItem(t, group, info)
	table.insert(t, "\n|}")
	return table.concat(t)
end

function m.main(f)
	local apiType = f.args.t
	local pageName = f.args.name
	local info = {
		apiType = apiType,
		strippedName = pageName:gsub("API ", "")
	}
	local group_infobox
	local expanded = f:expandTemplate(template)
	if apiType == "widget" then
		info.widget = pageName:match("UIOBJECT (%w+)")
		info.valid = true
	elseif apiType == "method" then
		info.widget, info.method = pageName:match("API (%w+) (%w+)")
		if not info.widget and not info.method then return end
		info.valid = true
		if group_data_module.data[info.widget.." "..info.method] then
			group_infobox = INFOBOX_STYLE:format(m:GetGroupInfobox(info))
		end
	elseif apiType == "script" and pageName:find("UIHANDLER") then
		info.script = pageName:match("UIHANDLER (%w+)")
		info.valid = true
		if group_data_module.data["UIHANDLER "..info.script] then
			group_infobox = INFOBOX_STYLE:format(m:GetGroupInfobox(info))
		end
	end
	return expanded..(info.valid and (group_infobox or m:GetInfobox(info)) or "")
end

return m
