require "FrameXML"

local missing = {
	["BountySharedDocumentation.lua"] = true,
}

-- load Blizzard_APIDocumentation
local toc = io.open("Blizzard_APIDocumentation/Blizzard_APIDocumentation.toc")
for line in toc:lines() do
	if line:find("%.lua") and not missing[line] then
		local file = assert(loadfile("Blizzard_APIDocumentation/"..line))
		file()
	end
end
toc:close()

require "MissingDocumentation"
require "Wowpedia/Wowpedia"
require "Exporter"

-- no unit tests yet
require "tests/Pages"
require "tests/Stats"
require "tests/Special"

ExportSystems()
