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
		{ Name = "CharacterAlternateFormData", Type = "Structure", Fields = {} }, -- BarberShopDocumentation.lua
		{ Name = "CurrencyCost", Type = "Structure", Fields = {} }, -- LegendaryCraftingDocumentation.lua
		{ Name = "GarrisonTalentTreeInfo", Type = "Structure", Fields = {} }, -- GarrisonInfoDocumentation.lua
		{ Name = "OptionalReagentInfo", Type = "Structure", Fields = {} }, -- TradeSkillUIDocumentation.lua
		{ Name = "QueueSpecificInfo", Type = "Structure", Fields = {} }, -- PartyInfoDocumentation.lua, SocialQueueDocumentation.lua
		{ Name = "RuneforgeLegendaryCraftDescription", Type = "Structure", Fields = {} }, -- LegendaryCraftingDocumentation.lua
		{ Name = "RuneforgePower", Type = "Structure", Fields = {} }, -- LegendaryCraftingDocumentation.lua
		{ Name = "SoulbindConduitType", Type = "Enumeration", Fields = {} }, -- SoulbindsDocumentation.lua
		{ Name = "SoulbindNodeState", Type = "Enumeration", Fields = {} }, -- SoulbindsDocumentation.lua
		{ Name = "WeeklyRewardChestThresholdType", Type = "Enumeration", Fields = {} }, -- WeeklyRewardsDocumentation.lua
	},
}

APIDocumentation:AddDocumentationTable(Missing)
