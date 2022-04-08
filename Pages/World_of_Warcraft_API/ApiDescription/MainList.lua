local WikiText = require("Pages/World_of_Warcraft_API/WikiText")
local Util = require("Util/Util")
local m = {}

function m:ParseWikitext(wikitext)
	local t = {}
	for line in string.gmatch(wikitext, "(.-)\n") do
		local name = line:match(":.-%[API (.-)|")
		local desc = line:match(" %- (.+)")
		if name and desc then
			t[name] = desc
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
