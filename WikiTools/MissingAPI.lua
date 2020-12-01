local globalapi = {
	"AbandonSkill",
	"AcceptAreaSpiritHeal",
	"AcceptBattlefieldPort",
}

local framexml = {
	"APIDocumentation_LoadUI",
	"AbbreviateLargeNumbers",
	"AbbreviateNumbers",
}

-- find in files
-- ^:.*?\[\[API .*?\|.*?.*

-- match
-- .*: :.*?\[\[API (.*?)\|.*

local function ToHashTable(tbl)
	local t = {}
	for _, v in pairs(tbl) do
		t[v] = true
	end
	return t
end

local function FindDuplicates()
	local t = {}
	for _, v in pairs(wowpedia) do
		if t[v] then
			print(v)
		else
			t[v] = true
		end
	end
end
-- FindDuplicates()

local function FindMissing()
	print("-- missing")
	local w = ToHashTable(wowpedia)
	for _, v in pairs(globalapi) do
		if not w[v] then
			print(v)
		end
	end
	print("\n-- unneeded")
	local g = ToHashTable(globalapi)
	local f = ToHashTable(framexml)
	for _, v in pairs(wowpedia) do
		if not g[v] and not f[v] then
			print(v)
		end
	end
end
FindMissing()
