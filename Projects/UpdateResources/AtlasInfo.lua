-- https://github.com/Ketho/BlizzardInterfaceResources/blob/mainline/Resources/AtlasInfo.lua
local parser = require("Util/wago_csv")

local columns = {
	["CommittedName"] = "Field_11_0_2_55665_000",
	["ID"] = "Field_11_0_2_55665_001",
	["UiTextureAtlasID"] = "Field_11_0_2_55665_002",
	["Width"] = "Field_11_0_2_55665_003",
	["Height"] = "Field_11_0_2_55665_004",
	["CommittedLeft"] = "Field_11_0_2_55665_005",
	["CommittedRight"] = "Field_11_0_2_55665_006",
	["CommittedTop"] = "Field_11_0_2_55665_007",
	["CommittedBottom"] = "Field_11_0_2_55665_008",
	["UiTextureAtlasElementID"] = "Field_11_0_2_55665_009",
	["OverrideWidth"] = "Field_11_0_2_55665_010",
	["OverrideHeight"] = "Field_11_0_2_55665_011",
	["CommittedFlags"] = "Field_11_0_2_55665_012",
	["UiCanvasID"] = "Field_11_0_2_55665_013",
}

local function SortTable(tbl, key)
	table.sort(tbl, function(a, b)
		return a[key] < b[key]
	end)
end

local function AtlasInfo(options)
	options = options or {}
	options.header = true
	local filedata = parser:ReadListfile()
	local uitextureatlas = parser:ReadCSV("uitextureatlas", options)
	local atlasTable, atlasOrder, atlasSize = {}, {}, {}
	for line in uitextureatlas:lines() do
		local atlasID = tonumber(line.ID)
		local fdid = tonumber(line.FileDataID)
		if atlasID then -- last csv line is empty
			atlasTable[atlasID] = {}
			table.insert(atlasOrder, {
				atlasID = atlasID,
				fdid = fdid,
				fileName = filedata[fdid] or tostring(fdid), -- listfile might not yet be updated
			})
			atlasSize[atlasID] = {
				width = tonumber(line.AtlasWidth),
				height = tonumber(line.AtlasHeight),
			}
		end
	end
	SortTable(atlasOrder, "fileName")

	local element_names = {}
	local uitextureatlaselement = parser:ReadCSV("uitextureatlaselement", options)
	for line in uitextureatlaselement:lines() do
		element_names[tonumber(line.ID)] = line.Name
	end

	local uitextureatlasmember = parser:ReadCSV("uitextureatlasmember", options)
	for line in uitextureatlasmember:lines() do
		-- 11.0.2 hack
		if not line.CommittedName then
			for k, v in pairs(columns) do
				line[k] = line[v]
			end
		end
		-- line.CommitedName is not a valid atlas id
		local name = element_names[tonumber(line.UiTextureAtlasElementID)]
		if name and name ~= "" then -- 1130222 interface/store/shop has empty atlas members
			local atlasID = tonumber(line.UiTextureAtlasID)
			local size = atlasSize[atlasID]
			if size then -- some issue with 3.4.1 CSVs
				local left = tonumber(line.CommittedLeft)
				local right = tonumber(line.CommittedRight)
				local top = tonumber(line.CommittedTop)
				local bottom = tonumber(line.CommittedBottom)
				line.CommittedFlags = tonumber(line.CommittedFlags) -- lua 5.4 attempt to perform bitwise operation on a string value
				table.insert(atlasTable[atlasID], {
					memberID = tonumber(line.ID),
					name = name,
					width = right - left,
					height = bottom - top,
					left = left / size.width,
					right = right / size.width,
					top = top / size.height,
					bottom = bottom / size.height,
					tileshoriz = line.CommittedFlags&0x4 > 0,
					tilesvert = line.CommittedFlags&0x2 > 0,
				})
			end
		end
	end

	local fsAtlas = '\t["%s"] = { -- %d\n'
	local fsMember = '\t\t["%s"] = {%d, %d, %s, %s, %s, %s, %s, %s},\n'

	print("writing "..OUT_ATLAS)
	local file = io.open(OUT_ATLAS, "w")
	file:write("---@diagnostic disable: duplicate-index\n")
	file:write("-- atlas = width, height, leftTexCoord, rightTexCoord, topTexCoord, bottomTexCoord, tilesHorizontally, tilesVertically\n")
	file:write("local AtlasInfo = {\n")
	for _, atlas in pairs(atlasOrder) do
		file:write(fsAtlas:format(atlas.fileName:match("(.+)%.blp") or atlas.fileName, atlas.fdid))
		for _, member in pairs(atlasTable[atlas.atlasID]) do
			file:write(fsMember:format(member.name, member.width, member.height,
				member.left, member.right, member.top, member.bottom,
				member.tileshoriz, member.tilesvert))
		end
		file:write("\t},\n")
	end
	file:write("}\n\nreturn AtlasInfo\n")
	file:close()
end

return AtlasInfo
