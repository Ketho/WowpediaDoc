-- https://github.com/ketho-wow/WardrobeSort/blob/master/Data/FileData.lua
-- https://github.com/ketho-wow/ClickMorph/blob/master/Data/Live/ItemAppearance.lua
local parser = require("util.wago")
local output = "out/ItemAppearance.lua"
local data = {}
local fd

local suffix = {
	"_al_[ufm]",
	"_au_[ufm]",
	"_fo_[ufm]",
	"_ha_[ufm]",
	"_ll_[ufm]",
	"_lu_[ufm]",
	"_tl_[ufm]",
	"_tu_[ufm]",
}

-- get texturefiledata first to verify itemdisplayinfomaterialres filedata
local order = {
	"texturefiledata",
	"itemdisplayinfomaterialres",
	"itemdisplayinfo",
	"itemappearance",
}

-- https://github.com/ketho-wow/WardrobeSort/wiki/Data-workflow
local handler = {
	itemappearance = function(iter)
		local t = {}
		for l in iter:lines() do
			local ID = tonumber(l.ID)
			if ID then
				t[ID] = tonumber(l.ItemDisplayInfoID)
			end
		end
		return t
	end,
	itemdisplayinfo  = function(iter)
		local t = {}
		for l in iter:lines() do
			local ID = tonumber(l.ID)
			if ID then
				t[ID] = tonumber(l.ModelMaterialResourcesID_0)
			end
		end
		return t
	end,
	-- there are multiple textures ids for the same itemdisplay ids
	-- so only the last occurrence will be saved
	itemdisplayinfomaterialres = function(iter)
		local t = {}
		for l in iter:lines() do
			local ID = tonumber(l.ItemDisplayInfoID)
			local MRID = tonumber(l.MaterialResourcesID)
			if ID and fd[data.texturefiledata[MRID]] then
				t[ID] = MRID
			end
		end
		return t
    end,
	texturefiledata = function(iter)
		local t = {}
		for l in iter:lines() do
			local ID = tonumber(l.MaterialResourcesID)
			if ID then
				t[ID] = tonumber(l.FileDataID)
			end
		end
		return t
    end,
}

local function ParseDBC(dbc, BUILD)
	local iter = parser:ReadCSV(dbc, {build=BUILD, header=true})
	return handler[dbc](iter)
end

local function ItemAppearance(BUILD)
	fd = parser:ReadListfile()
	for _, name in pairs(order) do
		print("reading "..name)
        data[name] = ParseDBC(name, BUILD)
	end
	local fs = '[%d]="%s",\n'

	print("writing "..output)
	local file = io.open(output, "w")
	file:write("local ItemAppearance = {\n")
	for id, val in pairs(data.itemappearance) do
		local idi = data.itemdisplayinfo[val]
		idi = idi and idi > 0 and idi
		local idimr = data.itemdisplayinfomaterialres[val]
		idimr = idimr and idimr > 0 and idimr
		local displayInfo = idi or idimr
		if displayInfo then
			local txfd = fd[data.texturefiledata[displayInfo]]
			if txfd then
				local visualName = txfd:match(".+/(.+)%.blp")
				for _, v in pairs(suffix) do
					visualName = visualName:gsub(v, "")
				end
				file:write(fs:format(id, visualName))
			end
		end
	end
	file:write("}\n\nreturn ItemAppearance\n")
	file:close()
	print("finished")
end

ItemAppearance()
