-- https://wowprogramming.com/docs/events.html
-- https://web.archive.org/web/20170519220226id_/http://wowprogramming.com/docs/events
-- https://warcraft.wiki.gg/wiki/Module:API_info/wowprog/event
local gumbo = require "gumbo"
local document = gumbo.parseFile("Scribunto/API_info/wowprog/event/event.html")

local util = require("wowdoc")

local class = document:getElementsByClassName("event-hack")
local api_elements = class[1].children[1]

local t = {}

for _, v in pairs(api_elements.children) do
	if type(v) == "table" then
		local el = v.children[1].children[1]
		if el then
			local description = v.children[2].textContent
			if not description:find("This event is not yet documented") then
				local name = el.textContent
				-- local url_part = el:getAttribute("href")
				t[name] = true
			end
		end
	end
end

for _, v in pairs(util:SortTable(t)) do
	print(v)
end
