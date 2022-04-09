local Util = require("Util/Util")
local FOLDER = "Pages/World_of_Warcraft_API/ApiDescription/"
local MainList = require(FOLDER.."MainList")
local PageDescription = require(FOLDER.."Pages")

local invalid = {
	-- "{protected",
	-- "Describe the purpose",
}

local function isValid(s)
	if s == "Needs summary." then
		return false
	else
		for _, v in pairs(invalid) do
			if s:find(v) then
				return false
			end
		end
	end
	return true
end

local function main()
	local mainList = MainList:main()
	-- for _, name in pairs(Util:SortTable(mainList)) do
	-- 	local desc = mainList[name]
	-- 	print(name, desc)
	-- end

	local pageDescriptions = PageDescription:main()
	-- for _, name in pairs(Util:SortTable(pageDescriptions)) do
	-- 	local desc = pageDescriptions[name]
	-- 	if isValid(desc) then
	-- 		print(name, desc)
	-- 	end
	-- end

	for _, k in pairs(Util:SortTable(mainList)) do
		local desc1 = mainList[k]
		local desc2 = pageDescriptions[k]
		-- if (not desc1 and desc2) or (desc1 and not desc2) then
		-- 	print(k, desc1, desc2)
		-- end
		if desc1 and desc2 and desc1~=desc2 then
			print(k)
			print("", desc1)
			print("", desc2)
		end
	end
end

main()
print("done")
