local WikiText = require("Pages/World of Warcraft API/WikiText")
local util = require("util")
local m = {}

function m:ParseWikitext(wikitext)
	local t = {}
	for line in string.gmatch(wikitext, "(.-)\n") do
		local name = line:match(":.-%[API (.-)|")
		local desc = line:match(" %- (.+)")
		if name then
			t[name] = desc or false
		end
	end
	return t
end

function m:main()
	WikiText:SaveExport()
	local text = WikiText:GetWikitext(true)
	local descTbl = m:ParseWikitext(text)
	return descTbl
end

return m
