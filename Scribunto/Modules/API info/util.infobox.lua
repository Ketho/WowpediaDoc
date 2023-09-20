--[[
local example = {
	"|+ title text",
	"! header 1",
	"| banana",
	"! header 2",
	{ -- html list
		{icon = "Inv_gizmo_01.png", url = "https://wowprogramming.com", text = "hello"},
		{icon = "Inv_gizmo_02.png", url = "https://www.google.com", iconsize = 24, text = "world"},
		{icon = "Inv_gizmo_03.png", url = "https://github.com", text = "apple"},
	},
}
]]
local m = {}
local INFOBOX_STYLE = '<div class="nomobile" style="float:right; clear:right">\n%s\n</div>'
local LIST_ITEM = '<li style="padding-left: 0px; min-height: 25px">%s</li>'

local function FormatListItem(item)
	item.iconsize = item.iconsize or 16
	local fs = item.fs or "[[File:$icon|$iconsize px|link=$url]] [$url $text]"
	return fs:gsub("%$(%w+)", item)
end

local function GetList(listitems)
	local t = {}
	table.insert(t, '<ul class="plainlinks elinks">')
	for _, v in pairs(listitems) do
		table.insert(t, LIST_ITEM:format(FormatListItem(v)))
	end
	table.insert(t, "</ul>")
	return table.concat(t, "\n")
end

local function GetDarktable(items)
	local t = {}
	table.insert(t, '{| class="darktable" style="min-width:142px;"')
	for _, v in pairs(items) do
		if type(v) == "table" then
			table.insert(t, "| "..GetList(v))
		else
			table.insert(t, v)
		end
	end
	table.insert(t, "|}")
	return table.concat(t, "\n|-\n")
end

function m:main(items, style)
	return (style or INFOBOX_STYLE):format(GetDarktable(items))
end

return m
