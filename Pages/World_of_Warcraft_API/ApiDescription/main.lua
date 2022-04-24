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

	local t = {}
	local fs = '\t["%s"] = [=[%s]=],'
	local fs_empy = '\t["%s"] = [=[Empty]=],'
	for _, k in pairs(Util:SortTable(mainList)) do
		local desc1 = mainList[k]
		local desc2 = pageDescriptions[k]
		if (desc1 and not desc2) or (not desc1 and desc2) then
			t[k] = desc1 or desc2
			print(fs:format(k, desc1 or desc2))
		end
		if desc1 and desc2 then
			if desc1~=desc2 then
				print(fs:format(k, desc1))
				print(fs:format(k, desc2))
				print()
			else
				print(fs:format(k, desc1))
			end
		end
		if not desc1 and not desc2 then
			print(fs_empy:format(k))
		end
	end
	print(t)
	-- for _, k in pairs(Util:SortTable(t)) do
	-- 	print(k, t[k])
	-- end
end

main()
print("done")
