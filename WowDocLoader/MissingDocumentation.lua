local Empty = {
	{ Name = "missing_structure", Type = "bool", EnumValue = 0 },
}

local Missing =
{
	Tables =
	{
		-- structures
		{
			-- MapDocumentation.lua
			Name = "UiMapPoint",
			Type = "Structure",
			Fields =
			{
				{ Name = "uiMapID", Type = "number" },
				{ Name = "position", Type = "vector2" },
				{ Name = "z", Type = "number", Nilable = true },
			},
		},
		{
			-- TooltipInfoDocumentation.lua (removed in 10.0.2)
			Name = "TooltipData",
			Type = "Structure",
			Fields =
			{
				{ Name = "type", Type = "TooltipDataType" },
				{ Name = "lines", Type = "table", InnerType = "TooltipDataLine" },
				{ Name = "args", Type = "table", InnerType = "TooltipDataArg" },
			},
		},
		{
			Name = "TooltipDataLine",
			Type = "Structure",
			Fields =
			{
				{ Name = "type", Type = "TooltipDataLineType" },
				{ Name = "args", Type = "table", InnerType = "TooltipDataArg" },
			},
		},
		{
			-- TooltipComparisonDocumentation.lua
			Name = "TooltipComparisonItem",
			Type = "Structure",
			Fields =
			{
				{ Name = "guid", Type = "WOWGUID" },
			},
		},
		{
			Name = "AuraData",
			Type = "Structure",
			Fields =
			{
				{ Name = "applications", Type = "number" },
				{ Name = "auraInstanceID", Type = "number" },
				{ Name = "canApplyAura", Type = "bool" },
				{ Name = "charges", Type = "number" },
				{ Name = "dispelName", Type = "string", Nilable = true },
				{ Name = "duration", Type = "number" },
				{ Name = "expirationTime", Type = "number" },
				{ Name = "icon", Type = "number" },
				{ Name = "isBossAura", Type = "bool" },
				{ Name = "isFromPlayerOrPlayerPet", Type = "bool" },
				{ Name = "isHarmful", Type = "bool" },
				{ Name = "isHelpful", Type = "bool" },
				{ Name = "isNameplateOnly", Type = "bool" },
				{ Name = "isRaid", Type = "bool" },
				{ Name = "isStealable", Type = "bool" },
				{ Name = "maxCharges", Type = "number" },
				{ Name = "name", Type = "string" },
				{ Name = "nameplateShowAll", Type = "bool" },
				{ Name = "nameplateShowPersonal", Type = "bool" },
				{ Name = "points", Type = "table", InnerType = "number" }, -- todo: check type
				{ Name = "sourceUnit", Type = "string", Nilable = true },
				{ Name = "spellId", Type = "number" },
				{ Name = "timeMod", Type = "number" },
			},
		},
		-- enums
		{
			-- WeeklyRewardsDocumentation.lua
			Name = "CachedRewardType",
			Type = "Enumeration",
			Fields =
			{
				{ Name = "None", Type = "CachedRewardType", EnumValue = 0 },
				{ Name = "Item", Type = "CachedRewardType", EnumValue = 1 },
				{ Name = "Currency", Type = "CachedRewardType", EnumValue = 2 },
				{ Name = "Quest", Type = "CachedRewardType", EnumValue = 3 },
			},
		},
		{
			-- WeeklyRewardsDocumentation.lua
			Name = "WeeklyRewardChestThresholdType",
			Type = "Enumeration",
			Fields =
			{
				{ Name = "None", Type = "WeeklyRewardChestThresholdType", EnumValue = 0 },
				{ Name = "MythicPlus", Type = "WeeklyRewardChestThresholdType", EnumValue = 1 },
				{ Name = "RankedPvP", Type = "WeeklyRewardChestThresholdType", EnumValue = 2 },
				{ Name = "Raid", Type = "WeeklyRewardChestThresholdType", EnumValue = 3 },
				{ Name = "AlsoReceive", Type = "WeeklyRewardChestThresholdType", EnumValue = 4 },
				{ Name = "Concession", Type = "WeeklyRewardChestThresholdType", EnumValue = 5 },
			},
		},
		{
			-- SoundDocumentation.lua (10.0.2)
			Name = "ItemSoundType",
			Type = "Enumeration",
			Fields = {
				{ Name = "Pickup", Type = "ItemSoundType ", EnumValue = 0 },
				{ Name = "Drop", Type = "ItemSoundType ", EnumValue = 1 },
				{ Name = "Use", Type = "ItemSoundType ", EnumValue = 2 },
				{ Name = "Close", Type = "ItemSoundType ", EnumValue = 3 },
			}
		},
		{
			-- CameraConstantsDocumentation.lua missing from manifest in 10.1.5 (50438)
			Name = "CameraModeAspectRatio",
			Type = "Enumeration",
			Fields = {
				{ Name = "Default", Type = "CameraModeAspectRatio ", EnumValue = 0 },
				{ Name = "LegacyLetterbox", Type = "CameraModeAspectRatio ", EnumValue = 1 },
				{ Name = "HighDefinition_16_X_9", Type = "CameraModeAspectRatio ", EnumValue = 2 },
				{ Name = "Cinemascope_2_Dot_4_X_1", Type = "CameraModeAspectRatio ", EnumValue = 3 },
			}
		},
		{
			-- in mainline but not in classic
			Name = "RoleShortageReward",
			Type = "Structure",
			Fields =
			{
				{ Name = "validRoles", Type = "table", InnerType = "cstring", Nilable = false },
				{ Name = "rewardSpellID", Type = "number", Nilable = false },
				{ Name = "rewardItemID", Type = "number", Nilable = false },
			},
		},

		-- 10.2.5
		{
			-- this is a table but not a structure
			Name = "LuaValueVariant",
			Type = "Structure",
			Fields =
			{
			},
		},
	},
}

APIDocumentation:AddDocumentationTable(Missing)

--[[
	{
		-- C_GuildInfo; GuildInfoDocumentation.lua
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
		-- C_MythicPlus; MythicPlusInfoDocumentation.lua; definition was removed from 9.1.5 but its still used
		Name = "MythicPlusAffixScoreInfo",
		Type = "Structure",
		Documentation = { "Information about a specific M+ run" },
		Fields =
		{
			{ Name = "name", Type = "string", Nilable = false },
			{ Name = "score", Type = "number", Nilable = false },
			{ Name = "level", Type = "number", Nilable = false },
			{ Name = "durationSec", Type = "number", Nilable = false },
			{ Name = "overTime", Type = "bool", Nilable = false },
		},
	},
	{
		-- C_TradeSkillUI; TradeSkillUIDocumentation.lua
		Name = "TradeSkillRecipeInfo",
		Type = "Structure",
		Fields =
		{
			{ Name = "alternateVerb", Type = "string", Nilable = true },
			{ Name = "categoryID", Type = "number" },
			{ Name = "craftable", Type = "bool" },
			{ Name = "difficulty", Type = "string" },
			{ Name = "disabled", Type = "bool" },
			{ Name = "favorite", Type = "bool" },
			{ Name = "hiddenUnlessLearned", Type = "bool" },
			{ Name = "icon", Type = "number" },
			{ Name = "learned", Type = "bool" },
			{ Name = "name", Type = "string" },
			{ Name = "nextRecipeID", Type = "number", Nilable = true },
			{ Name = "numAvailable", Type = "number" },
			{ Name = "numIndents", Type = "number" },
			{ Name = "numSkillUps", Type = "number" },
			{ Name = "previousRecipeID", Type = "number", Nilable = true },
			{ Name = "productQuality", Type = "number" },
			{ Name = "recipeID", Type = "number" },
			{ Name = "sourceType", Type = "number" },
			{ Name = "type", Type = "string" },
		},
	},
	{
		-- C_TransmogCollection; TransmogItemsDocumentation.lua
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
	structures which are not copied to the new file, but only exist in the old file which is not loaded from TOC
	{
		-- BountiesDocumentation.lua -> QuestLogDocumentation.lua; 9.0.1 (34615)
		Name = "BountyInfo",
		Type = "Structure",
		Fields =
		{
			{ Name = "questID", Type = "number", Nilable = false },
			{ Name = "factionID", Type = "number", Nilable = false },
			{ Name = "icon", Type = "number", Nilable = false },
			{ Name = "numObjectives", Type = "number", Nilable = false },
			{ Name = "turninRequirementText", Type = "string", Nilable = true },
		},
	},
	{
		-- CharacterCustomizationDocumentation.lua -> Blizzard_APIDocumentation\BarberShopDocumentation.lua; 9.0.1 (34615)
		Name = "CharCustomizationCategory",
		Type = "Structure",
		Fields =
		{
			{ Name = "id", Type = "number", Nilable = false },
			{ Name = "orderIndex", Type = "number", Nilable = false },
			{ Name = "name", Type = "string", Nilable = false },
			{ Name = "icon", Type = "string", Nilable = false },
			{ Name = "selectedIcon", Type = "string", Nilable = false },
			{ Name = "options", Type = "table", InnerType = "CharCustomizationOption", Nilable = false },
		},
	},
	enums used in apidocs
	{
		-- CurrencyConstantsDocumentation.lua
		Name = "SoulbindConduitTransactionType",
		Type = "Enumeration",
		Fields =
		{
			{ Name = "Install", Type = "SoulbindConduitTransactionType", EnumValue = 0 },
			{ Name = "Uninstall", Type = "SoulbindConduitTransactionType", EnumValue = 1 },
		},
	},
	{
		-- SoulbindsDocumentation.lua
		Name = "SoulbindConduitType",
		Type = "Enumeration",
		Fields =
		{
			{ Name = "Finesse", Type = "SoulbindConduitType", EnumValue = 0 },
			{ Name = "Potency", Type = "SoulbindConduitType", EnumValue = 1 },
			{ Name = "Endurance", Type = "SoulbindConduitType", EnumValue = 2 },
			{ Name = "Flex", Type = "SoulbindConduitType", EnumValue = 3 },
		},
	},
	{
		-- SoulbindsDocumentation.lua
		Name = "SoulbindNodeState",
		Type = "Enumeration",
		Fields =
		{
			{ Name = "Unavailable", Type = "SoulbindNodeState", EnumValue = 0 },
			{ Name = "Unselected", Type = "SoulbindNodeState", EnumValue = 1 },
			{ Name = "Selectable", Type = "SoulbindNodeState", EnumValue = 2 },
			{ Name = "Selected", Type = "SoulbindNodeState", EnumValue = 3 },
		},
	},
	{
		-- GamePadDocumentation.lua
		Name = "GamePadPowerLevel",
		Type = "Enumeration",
		Fields = {
			{ Name = "Critical", Type = "GamePadPowerLevel", EnumValue = 0 },
			{ Name = "Low", Type = "GamePadPowerLevel", EnumValue = 1 },
			{ Name = "Medium", Type = "GamePadPowerLevel", EnumValue = 2 },
			{ Name = "High", Type = "GamePadPowerLevel", EnumValue = 3 },
			{ Name = "Wired", Type = "GamePadPowerLevel", EnumValue = 4 },
			{ Name = "Unknown", Type = "GamePadPowerLevel", EnumValue = 5 },
		}
	},
]]
