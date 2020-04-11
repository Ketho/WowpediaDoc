
require "FrameXML"

local toc = io.open("Blizzard_APIDocumentation/Blizzard_APIDocumentation.toc")
for line in toc:lines() do
	if line:find("%.lua") then
		require("Blizzard_APIDocumentation/"..line:gsub("%.lua", ""))
	end
end
toc:close()

local function test(apiType)
	local apiTable = APIDocumentation:GetAPITableByTypeName(apiType)
	for i, apiInfo in ipairs(apiTable) do
		print(i, apiInfo.Name)
	end
end
test("system")
