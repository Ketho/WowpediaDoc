local Util = require("Util/Util")
local FOLDER = "Pages/World_of_Warcraft_API/ApiDescription/"
local MainList = require(FOLDER.."MainList")
local PageDescription = require(FOLDER.."Pages")

local function main()
	local mainList = MainList:main()
	for _, name in pairs(Util:SortTable(mainList)) do
		local desc = mainList[name]
		print(name, desc)
	end
	print("\n-----\n")
	local pageDescriptions = PageDescription:main()
	for _, name in pairs(Util:SortTable(pageDescriptions)) do
		local desc = pageDescriptions[name]
		print(name, desc)
	end
end

main()
print("done")
