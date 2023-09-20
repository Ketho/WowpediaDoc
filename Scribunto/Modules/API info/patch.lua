local data
local m = {}

local function GetData(apiType)
	local api_types = {
		a = "api",
		e = "event",
	}
	if api_types[apiType] then
		local t = {
			[apiType] = {
				retail = mw.loadData(string.format("Module:API_info/patch/%s_retail", api_types[apiType])),
				classic = mw.loadData(string.format("Module:API_info/patch/%s_classic", api_types[apiType])),
			}
		}
		return t
	end
end

local function GetLink(patch)
	return string.format("[[Patch_%s/API_changes|%s]]", patch, patch)
end

function m:GetPatches(apiType, name)
	data = data or GetData(apiType)
	local addedTbl, removedTbl = {}, {}
	local patch = {
		retail = data[apiType].retail[name],
		classic = data[apiType].classic[name],
	}
	if patch.retail then
		if patch.retail[1] then
			table.insert(addedTbl, GetLink(patch.retail[1]))
		end
		if patch.retail[2] then
			table.insert(removedTbl, GetLink(patch.retail[2]))
		end
	end
	if patch.classic then
		if patch.classic[1] then
			table.insert(addedTbl, GetLink(patch.classic[1]))
		end
		if patch.classic[2] then
			table.insert(removedTbl, GetLink(patch.classic[2]))
		end
	end
	local addedStr = table.concat(addedTbl, " / ")
	local removedStr = table.concat(removedTbl, " / ")
	return addedStr, removedStr
end

function m:IsPTR(apiType, name, ptrVersion)
	data = data or GetData(apiType)
	local patch = data[apiType].retail[name]
	return patch and patch[1] == ptrVersion
end

return m
