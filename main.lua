require "FrameXML"

local missing = {
	["BountySharedDocumentation.lua"] = true,
}

-- load Blizzard_APIDocumentation
local toc = io.open("Blizzard_APIDocumentation/Blizzard_APIDocumentation.toc")
for line in toc:lines() do
	if line:find("%.lua") and not missing[line] then
		require("Blizzard_APIDocumentation/"..line:gsub("%.lua", ""))
	end
end
toc:close()

require "MissingDocumentation"
require "Wowpedia/Wowpedia"
require "Exporter"

require "tests/Pages"
require "tests/Stats"
require "tests/Special"

ExportSystems()
