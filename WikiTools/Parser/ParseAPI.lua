local FrameXML = require("FrameXML/FrameXML")
FrameXML:LoadApiDocs("FrameXML")
require "Wowpedia/Wowpedia"
local WikiText = require "WikiTools/WikiText"

local file = io.open("WikiTools/Parser/World_of_Warcraft_API.txt", "r")
local newFile = io.open("WikiTools/Parser/World_of_Warcraft_API_out.txt", "w")

local tags = {
	SECURE = true,
	COMBAT = true,
	HW = true,
	UI = true,
}

local signatures = WikiText:GetSignatures()

for line in file:lines() do
	local newStr
	if line:match("^: (.-)") then
		local tag = line:match("^: <small>(.-)</small>")
		local name = line:match("%[%[API (.-)|")
		--local args = line:match("%((.-)%)")
		--local returns = line:match("%) : (.+</span>)")
		local desc = line:match("%) %- (.+)") or line:match("%</span> %- (.+)")
		-- UI can have both styles of text formatting
		if  signatures[name] and (not tag or (tags[tag] and tag ~= "UI")) then
			if tag then -- format tags back in
				signatures[name] = signatures[name]:gsub("^: ", ": <small>"..tag.."</small> ")
			end
			desc = desc and " - "..desc or ""
			newStr = signatures[name]..desc
		end
	end
	newFile:write((newStr or line).."\n")
end

file:close()
newFile:close()
print("done!")
