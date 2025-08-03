local util = require("wowdoc")
local FOLDER = "Pages/World of Warcraft API/ApiDescription/"
local MainList = require(FOLDER.."MainList")
local PageDescription = require(FOLDER.."Pages")

local invalid = {
	-- "{protected",
	-- "Describe the purpose",
}

local filter_different = {
	["C_Timer.NewTimer"] = true,
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

local function main(descType)
	local mainList = MainList:main()
	-- for _, name in pairs(util:SortTable(mainList)) do
	-- 	local desc = mainList[name]
	-- 	print(name, desc)
	-- end

	local pageDescriptions = PageDescription:main()
	-- for _, name in pairs(util:SortTable(pageDescriptions)) do
	-- 	local desc = pageDescriptions[name]
	-- 	if isValid(desc) then
	-- 		print(name, desc)
	-- 	end
	-- end

	local t = {}
	local fs = '\t["%s"] = [=[%s]=],'
	local fs_empy = '\t["%s"] = [=[Empty]=],'

	-- print("\n-- matching")
	-- for _, k in pairs(util:SortTable(mainList)) do
	-- 	local desc1 = mainList[k]
	-- 	local desc2 = pageDescriptions[k]
	-- 	if desc1 and desc2 then
	-- 		if desc1==desc2 then
	-- 			print(fs:format(k, desc1))
	-- 		end
	-- 	end
	-- end

	print("\n-- different")
	for _, k in pairs(util:SortTable(mainList)) do
		local desc1 = mainList[k]
		local desc2 = pageDescriptions[k]
		if desc1 and desc2 and desc1 ~= desc2 and not filter_different[k] then
			-- print(fs:format(k, desc1, desc2))
			print(k)
			print("", desc1)
			print("", desc2)
		end
	end

	-- print("\n-- either")
	-- for _, k in pairs(util:SortTable(mainList)) do
	-- 	local desc1 = mainList[k]
	-- 	local desc2 = pageDescriptions[k]
	-- 	if (desc1 and not desc2) or (not desc1 and desc2) then
	-- 		local s = desc1 or desc2
	-- 		print(fs:format(k, s))
	-- 	end
	-- end

	-- print("\n-- empty")
	-- for _, k in pairs(util:SortTable(mainList)) do
	-- 	local desc1 = mainList[k]
	-- 	local desc2 = pageDescriptions[k]
	-- 	if not desc1 and not desc2 then
	-- 		print(fs_empy:format(k))
	-- 	end
	-- end
end

main()
print("done")
