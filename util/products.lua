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
	wow = "live", -- 11.1.7
	wowt = "ptr", -- 11.1.7
	wowxptr = "ptr2", -- 11.2.0
	wow_beta = "beta", -- 11.0.2
	-- classic
	wow_classic = "classic", -- 5.5.0
	wow_classic_ptr = "classic_ptr", -- 5.5.0
	wow_classic_beta = "classic_beta", -- 5.5.0
	-- vanilla
	wow_classic_era = "classic_era", -- 1.15.7
	wow_classic_era_ptr = "classic_era_ptr", -- 1.15.7
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

	wow_classic_era = "classic_era",
	wow_classic_era_ptr = "classic_era_ptr",
}

return m
