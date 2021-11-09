local Util = require "Util/Util"
local WikiText = require "Pages/World_of_Warcraft_API/Signatures_WikiText"

local m = {}
-- this has to be done manually because symbols get turned into HTML char codes when downloaded
local WIKIPAGE_PATH = "cache_lua/World_of_Warcraft_API.txt"
local WIKIPAGE_PATH_TEMP = "cache_lua/World_of_Warcraft_API_out.xml"

function m:UpdateSignatures(signatures)
	local file_cur = io.open(WIKIPAGE_PATH, "r")
	local file_temp = io.open(WIKIPAGE_PATH_TEMP, "w")
	for line in file_cur:lines() do
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
		file_temp:write((newStr or line).."\n")
	end
	file_cur:close()
	file_temp:close()
	os.remove(WIKIPAGE_PATH)
	os.rename(WIKIPAGE_PATH_TEMP, WIKIPAGE_PATH)
end

local function main()
	local signatures = WikiText:GetSignatures()
	m:UpdateSignatures(signatures)
end

main()
print("done")
