-- https://wago.tools/
local m = {}

---@alias TactProduct string
---|"wow"
---|"wowt"
---|"wowxptr"
---|"wow_beta"
---|"wow_classic"
---|"wow_classic_ptr"
---|"wow_classic_beta"
---|"wow_classic_era"
---|"wow_classic_era_ptr"

---@alias GetheBranch string
---|"live"
---|"ptr"
---|"ptr2"
---|"beta"
---|"classic"
---|"classic_ptr"
---|"classic_beta"
---|"classic_era"
---|"classic_era_ptr"

---@alias BlizzResBranch string
---|"mainline"
---|"mainline_ptr"
---|"mainline_beta"
---|"mists"
---|"mists_ptr"
---|"mists_beta"
---|"cata"
---|"cata_ptr"
---|"vanilla"
---|"vanilla_ptr"

---@type table<TactProduct, GetheBranch>
m.gethe_branch = {
	-- mainline
	wow = "live",
	wowt = "ptr",
	wowxptr = "ptr2",
	wow_beta = "beta",
	-- classic
	wow_classic = "classic",
	wow_classic_ptr = "classic_ptr",
	wow_classic_beta = "classic_beta",
	-- vanilla
	wow_classic_era = "classic_era",
	wow_classic_era_ptr = "classic_era_ptr",
}

---@type table<TactProduct, BlizzResBranch>
m.blizzres_branch = {
	wow = "mainline",
	wowt = "mainline_ptr",
	wowxptr = "mainline_ptr",
	wow_beta = "mainline_beta",
	wow_classic = "mists",
	wow_classic_ptr = "mists_ptr",
	wow_classic_beta = "mists_beta",
	wow_classic_era = "vanilla",
	wow_classic_era_ptr = "vanilla_ptr",
}

return m
