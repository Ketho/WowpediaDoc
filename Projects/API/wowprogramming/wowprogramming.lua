-- https://wowprogramming.com/docs/api.html
local gumbo = require "gumbo"
local document = gumbo.parseFile("Projects/API/wowprogramming/api.html")

local Util = require("Util/Util")

local api_alpha = document:getElementsByClassName("api-alpha")
local api_elements = api_alpha[1].children[2]

local t = {}

for _, v in pairs(api_elements.children) do
	if type(v) == "table" then
		local el = v.children[1].children[1]
		if el then
			local description = v.children[2].textContent
			if not description:find("This function is not yet documented") then
				local name = el.textContent
				-- local url_part = el:getAttribute("href")
				t[name] = true
			end
		end
	end
end

-- there are some duplicates, e.g. acos and print
-- but could also just do this manually
for _, v in pairs(Util:SortTable(t)) do
	print(v)
end
