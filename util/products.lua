-- https://wago.tools/
local m = {}

m.products = {
	wow = "wow",
	wowt = "wowt",
	wowxptr = "wowxptr",
	wow_beta = "wow_beta",
	wow_classic = "wow_classic",
	wow_classic_ptr = "wow_classic_ptr",
	wow_classic_beta = "wow_classic_beta",
	wow_classic_era = "wow_classic_era",
	wow_classic_era_ptr = "wow_classic_era_ptr",
}

-- wow product to gethe branch
m.product_branch = {
	wow = "live", -- 11.1.7
	wowt = "ptr", -- 11.1.7
	wowxptr = "ptr2", -- 11.2.0
	wow_beta = "beta",
	-- classic
	wow_classic = "classic", -- 5.5.0
	wow_classic_ptr = "classic_ptr", -- 5.5.0
	wow_classic_beta = "classic_beta",
	-- vanilla
	wow_classic_era = "classic_era", -- 1.15.7
	wow_classic_era_ptr = "classic_era_ptr", -- 1.15.7
}

m.branch_product = {}
for k, v in pairs(m.product_branch) do
    m.branch_product[v] = k
end

return m
