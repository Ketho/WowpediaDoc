local write_table = require("Util/write_table")

local flavors = {
	retail = {
		id = "retail",
		input = "FrameXML/retail",
		out = "out/lua/API_info.patch.event_retail.lua",
	},
	classic = {
		id = "classic",
		input = "FrameXML/classic",
		out = "out/lua/API_info.patch.event_classic.lua",
	},
}

-- get event patch data from >8.0.1 blizzard api docs
local BlizzardApiDoc = require("Scribunto/API_info/patch/event/BlizzardApiDoc")
local tbl_apidoc = BlizzardApiDoc:main(flavors)

-- get older event data by looking through framexml
local FrameXML = require("Scribunto/API_info/patch/event/FrameXML")
local tbl_framexml = FrameXML:main(flavors, tbl_apidoc)

-- fill in false values
for k, v in pairs(tbl_framexml) do
	tbl_apidoc[k][1] = v
end

write_table(tbl_apidoc, "data", flavors.retail.out)
print("done")
