local Empty = {
	{ Name = "Undocumented", Type = "bool" },
}

local Missing =
{
	Tables =
	{
		{
			-- C_Calendar
			Name = "CalendarTime",
			Type = "Structure",
			Fields =
			{
				{ Name = "year", Type = "number" },
				{ Name = "month", Type = "number" },
				{ Name = "monthDay", Type = "number" },
				{ Name = "weekday", Type = "number" },
				{ Name = "hour", Type = "number" },
				{ Name = "minute", Type = "number" },
			},
		},
		{
			-- C_GuildInfo
			Name = "GuildTabardInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "backgroundColor", Type = "table", Mixin = "ColorMixin" },
				{ Name = "borderColor", Type = "table", Mixin = "ColorMixin" },
				{ Name = "emblemColor", Type = "table", Mixin = "ColorMixin" },
				{ Name = "emblemFileID", Type = "number" },
				{ Name = "emblemStyle", Type = "number" },
			},
		},
		{
			-- C_TransmogCollection
			Name = "AppearanceSourceInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "categoryID", Type = "number" },
				{ Name = "invType", Type = "number" },
				{ Name = "isCollected", Type = "bool" },
				{ Name = "isHideVisual", Type = "bool", Nilable = true },
				{ Name = "itemID", Type = "number" },
				{ Name = "itemModID", Type = "number" },
				{ Name = "name", Type = "string", Nilable = true },
				{ Name = "quality", Type = "number", Nilable = true },
				{ Name = "sourceID", Type = "number" },
				{ Name = "sourceType", Type = "number", Nilable = true },
				{ Name = "visualID", Type = "number" },
			},
		},
		-- placeholders
		{ Name = "CachedRewardType", Type = "Enumeration", Fields = Empty }, -- WeeklyRewardsDocumentation.lua
		{ Name = "CharacterAlternateFormData", Type = "Structure", Fields = Empty }, -- BarberShopDocumentation.lua
		{ Name = "CurrencyCost", Type = "Structure", Fields = Empty }, -- LegendaryCraftingDocumentation.lua
		{ Name = "GarrisonTalentTreeInfo", Type = "Structure", Fields = Empty }, -- GarrisonInfoDocumentation.lua
		{ Name = "OptionalReagentInfo", Type = "Structure", Fields = Empty }, -- TradeSkillUIDocumentation.lua
		{ Name = "QueueSpecificInfo", Type = "Structure", Fields = Empty }, -- PartyInfoDocumentation.lua, SocialQueueDocumentation.lua
		{ Name = "RuneforgeItemPreviewInfo", Type = "Structure", Fields = Empty }, -- LegendaryCraftingDocumentation.lua
		{ Name = "RuneforgeLegendaryComponentInfo", Type = "Structure", Fields = Empty }, -- LegendaryCraftingDocumentation.lua
		{ Name = "RuneforgeLegendaryCraftDescription", Type = "Structure", Fields = Empty }, -- LegendaryCraftingDocumentation.lua
		{ Name = "RuneforgePower", Type = "Structure", Fields = Empty }, -- LegendaryCraftingDocumentation.lua
		{ Name = "SoulbindConduitTransactionType", Type = "Enumeration", Fields = Empty }, -- CurrencyConstantsDocumentation.lua; beta 9.0.2 (36401)
		{ Name = "SoulbindConduitType", Type = "Enumeration", Fields = Empty }, -- SoulbindsDocumentation.lua
		{ Name = "SoulbindNodeState", Type = "Enumeration", Fields = Empty }, -- SoulbindsDocumentation.lua
		{ Name = "TradeSkillRecipeInfo", Type = "Structure", Fields = Empty }, -- TradeSkillUIDocumentation.lua
		{ Name = "WeeklyRewardChestThresholdType", Type = "Enumeration", Fields = Empty }, -- WeeklyRewardsDocumentation.lua
	},
}

APIDocumentation:AddDocumentationTable(Missing)
