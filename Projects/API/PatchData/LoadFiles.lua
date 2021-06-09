local lfs = require "lfs"

local PATH = "Projects/API/PatchData/api"

local t = {}

for fileName in lfs.dir(PATH) do
	local patch = fileName:match("(.+)%.lua")
	if patch then
		table.insert(t, {
			version = patch,
			data = loadfile(PATH.."/"..fileName)()
		})
	end
end

table.sort(t, function(a, b)
	local major_a, minor_a, patch_a = a.version:match("(%d+)%.(%d+)%.(%d+)")
	local major_b, minor_b, patch_b = b.version:match("(%d+)%.(%d+)%.(%d+)")
	major_a, minor_a, patch_a = tonumber(major_a), tonumber(minor_a), tonumber(patch_a)
	major_b, minor_b, patch_b = tonumber(major_b), tonumber(minor_b), tonumber(patch_b)
	if major_a ~= major_b then
		return major_a < major_b
	elseif minor_a ~= minor_b then
		return minor_a < minor_b
	elseif patch_a ~= patch_b then
		return patch_a < patch_b
	end
end)

return t
