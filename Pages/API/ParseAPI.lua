-- automatically adds/updates blizzard-documented arguments and return values to listed api
local WikiText = require "Pages/API/WikiText"

local file = io.open("Pages/API/World_of_Warcraft_API.txt", "r")
local newFile = io.open("Pages/API/World_of_Warcraft_API_out.txt", "w")

local tags = {
	SECURE = true,
	NOCOMBAT = true,
	HW = true,
	--UI = true,
	--Lua = true,
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
		if signatures[name] then
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
