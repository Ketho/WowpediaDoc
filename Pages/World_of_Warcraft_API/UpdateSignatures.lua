local WikiText = require "Projects/API/UpdateSignatures_WikiText"

local fileName = "Projects/API/World_of_Warcraft_API.txt"
local fileName_temp = "Projects/API/World_of_Warcraft_API_temp.txt"

local file = io.open(fileName, "r")
local file_temp = io.open(fileName_temp, "w")

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
	file_temp:write((newStr or line).."\n")
end

file:close()
file_temp:close()

os.remove(fileName)
os.rename(fileName_temp, fileName)
print("done")
