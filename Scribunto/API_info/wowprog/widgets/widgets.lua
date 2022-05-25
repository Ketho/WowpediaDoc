-- https://wowprogramming.com/docs/widgets.html
-- https://wowpedia.fandom.com/wiki/Module:API_info/wowprog/widgets
local Util = require("Util/Util")

local file = io.open("Scribunto/API_info/wowprog/widgets/widgets.html", "r")
local text = file:read("a")

local t = {}

for s in text:gmatch('<a href="(.-)"') do
	local widget, method = s:match("docs/widgets/(%w-)/(%w-)%.html")
	if widget then
		t[widget..":"..method] = true
	end
end

for _, k in pairs(Util:SortTable(t)) do
	print(k)
end
