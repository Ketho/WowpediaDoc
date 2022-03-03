local Util = require("Util/Util")
local WikiText = require("Pages/World_of_Warcraft_API/WikiText")
local Signatures = require("Pages/World_of_Warcraft_API/Signatures_Parse")

local OUTPUT = "cache_lua/World_of_Warcraft_API.txt"
local m = {}

function m:UpdateSignatures(signatures)
	local wikitext = WikiText:GetWikitext().."\n"
	local file = io.open(OUTPUT, "w")
	for line in string.gmatch(wikitext, "(.-)\n") do
		line = WikiText:ReplaceHtml(line)
		local newStr
		if line:match("^: (.-)") then
			local tag = line:match("^: <small>(.-)</small>")
			local name = line:match("%[%[API (.-)|")
			--local args = line:match("%((.-)%)")
			--local returns = line:match("%) : (.+</span>)")
			local desc = line:match("%) %- (.+)") or line:match("%</span> %- (.+)")
			if signatures[name] then
				if tag then -- format tags back in
					signatures[name] = signatures[name]:gsub("^: ", ": <small>"..tag.."</small> ")
				end
				desc = desc and " - "..desc or ""
				newStr = signatures[name]..desc
			end
		end
		file:write((newStr or line).."\n")
	end
	file:close()
end

local function main()
	WikiText:SaveExport()
	local signatures = Signatures:GetSignatures()
	m:UpdateSignatures(signatures)
end

main()
print("done")
