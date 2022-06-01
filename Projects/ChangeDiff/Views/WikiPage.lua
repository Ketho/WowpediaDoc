local m = {}

local url_fs = "https://wowpedia.fandom.com/wiki/API_%s"
local patch_fs1 = "* {{Patch %s|note=Added <code>%s</code> %s.}}"
local patch_fs2 = "* {{Patch %s|note=Added.}}"

local paramTypeWord = {
	Arguments = "argument",
	Returns = "return",
	Payload = "param",
	Fields = "field",
}

local function SortReverse(a, b)
	return a > b
end

local function concatName(tbl)
	local t = {}
	for _, v in pairs(tbl) do
		table.insert(t, v.name)
	end
	return table.concat(t, ", ")
end

-- I cba writing proper code anymore. which was a mistake
function m:GetChangelog(paramHistory, tbl)
	local t = {}
	for name, info in pairs(paramHistory[tbl.name]) do
		t[info.build] = t[info.build] or {}
		table.insert(t[info.build], {
			name = name,
			idx = info.idx,
			paramType = info.paramType
		})
	end
	Print(tbl.build, url_fs:format(tbl.name))
	local basePatch = tbl.build:match("%d+%.%d+%.%d+")
	Print("==Patch changes==")
	local text = {}
	for _, k in pairs(Util:SortTable(t, SortReverse)) do
		local paramArray = t[k]
		table.sort(paramArray, function(a, b)
			return a.idx < b.idx
		end)
		local patch = k:match("%d+%.%d+%.%d+")
		if patch ~= basePatch then
			local paramWord = paramTypeWord[paramArray[1].paramType]
			if #paramArray > 1 then
				paramWord = paramWord.."s"
			end
			Print(patch_fs1:format(patch, concatName(paramArray, ", "), paramWord))
			table.insert(text, patch_fs1:format(patch, concatName(paramArray, ", "), paramWord))
		else
			Print(patch_fs2:format(basePatch))
			table.insert(text, patch_fs2:format(basePatch))
		end
	end
	Print()
	return table.concat(text, "\n")
end
