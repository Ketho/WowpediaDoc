local util = require("util")
local log = require("util.log")
local m = ChangeDiff

local function CompareApiTable(a, b)
	local added = {}
	for k, v in pairs(b) do
		if a[k] == nil then
			added[k] = v
		end
	end
	local removed, modified = {}, {}
	for k, v in pairs(a) do
		if b[k] == nil then
			removed[k] = v
		else
			if not util:equals(v, b[k]) then
				modified[k] = {v, b[k]}
			end
		end
	end
	return {added, removed, modified}
end

function m:CompareVersions(versions, framexml)
	local ver_a, ver_b = table.unpack(versions)
	log:info(string.format("Comparing %s to %s ", ver_a, ver_b))
	local frame_a = framexml[ver_a]
	local frame_b = framexml[ver_b]
	local changes = {}
	for k in pairs(self.apiTypes) do
		changes[k] = CompareApiTable(frame_a[k], frame_b[k])
	end
	return changes
end
