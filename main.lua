require "FrameXML"

local toc = io.open("Blizzard_APIDocumentation/Blizzard_APIDocumentation.toc")
for line in toc:lines() do
	if line:find("%.lua") then
		require("Blizzard_APIDocumentation/"..line:gsub("%.lua", ""))
	end
end
toc:close()

print("hello main")
require("Wowpedia/Wowpedia")
