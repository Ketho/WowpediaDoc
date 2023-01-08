-- https://wowprogramming.com/docs/widgets.html
-- https://wowpedia.fandom.com/wiki/Module:API_info/main/widget
local Util = require("Util/Util")
local gumbo = require("gumbo")

local path = "Scribunto/API_info/wowprog/widgets/widgets.html"
local file = io.open(path, "r")
local text = file:read("a")

-- some links are not red but are empty undocumented pages anyway
local undoc = {}
for s in text:gmatch('(%w+:%w+)%(%)</a> %- <em>This function is not yet documented</em>') do
	undoc[s] = true
end
file:close()

local document = assert(gumbo.parseFile(path))

local t = {}
for i, element in ipairs(document.links) do
	local href = element:getAttribute("href")
	local class = element:getAttribute("class")
	if href:find("/docs/widgets/%w+/") and not class then
		local widget, method = href:match("widgets/(%w+)/(%w+)")
		local fullName = widget..":"..method
		-- seems to be just SetSmoothProgress and GetDontSavePosition
		if not undoc[fullName] then
			t[widget..":"..method] = true
		end
	end
end

for _, k in pairs(Util:SortTable(t)) do
	print(k)
end
