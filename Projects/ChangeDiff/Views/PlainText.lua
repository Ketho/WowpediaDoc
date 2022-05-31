local Util = require("Util/Util")

local m = {}
local apiType_order = {"Function", "Event", "Structure"}

function m:PrintView(changes)
	for _, apiType in pairs(apiType_order) do
		print("-- "..apiType)
		local info = changes[apiType]
		for _, name in pairs(Util:SortTable(info[1])) do
			print("+ "..name)
		end
		for _, name in pairs(Util:SortTable(info[2])) do
			print("- "..name)
		end
		for _, name in pairs(Util:SortTable(info[3])) do
			print("# "..name)
		end
		print()
	end
	-- for _, name in pairs(Util:SortTable(b)) do
	-- 	if a[name] and b[name] then
	-- 		for _, paramTblName in pairs(paramTblNames) do
	-- 			local leftParam, rightParam = a[name][paramTblName], b[name][paramTblName]
	-- 			local diff = self:GetStructureDiff(leftParam, rightParam)
	-- 			if #diff > 0 then
	-- 				t.modified[name] = diff
	-- 				Util:Print("#", name)
	-- 				if #paramTblNames > 1 then
	-- 					Util:Print("", "# "..paramTblName)
	-- 				end
	-- 				for _, param in pairs(diff) do
	-- 					Util:Print("", param[1], param[2])
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end
end

-- function m:GetStructureDiff(a, b)
-- 	local diff = {}
-- 	local left, right = {}, {}
-- 	-- structure was added
-- 	if not a and b then
-- 		for _, param in pairs(b) do
-- 			table.insert(right, {"+", param.Name})
-- 			Util:Print("", "+++")
-- 		end
-- 	-- structure was removed
-- 	elseif a and not b then
-- 		for _, param in pairs(a) do
-- 			table.insert(left, {"-", param.Name})
-- 			Util:Print("", "---")
-- 		end
-- 	-- structure is possibly modified
-- 	elseif a and b then
-- 		for _, param in pairs(a) do
-- 			left[param.Name] = true
-- 		end
-- 		for _, param in pairs(b) do
-- 			right[param.Name] = true
-- 		end
-- 	end
-- 	for name in pairs(left) do
-- 		if not right[name] then
-- 			table.insert(diff, {"-", name})
-- 		end
-- 	end
-- 	for name in pairs(right) do
-- 		if not left[name] then
-- 			table.insert(diff, {"+", name})
-- 		end
-- 	end
-- 	return diff
-- end

return m
