local mixins = require("out/Mixins")
local templates = require("out/Templates")

local mixinTbl = {}
for _, v in pairs(mixins) do
	mixinTbl[v] = true
end

print("-- missing mixins:")
for k, v in pairs(templates) do
	if v.mixin then
		if v.mixin:find(",") then
			for part in v.mixin:gmatch("[^%s,]+") do
				if not mixinTbl[part] then
					print(k, part)
				end
			end
		elseif not mixinTbl[v.mixin] then
			print(k, v.mixin)
		end
	end
end

print("\n-- missing templates:")
for k, v in pairs(templates) do
	if v.inherits then
		if v.inherits:find(",") then
			for part in v.inherits:gmatch("[^%s,]+") do
				if not templates[part] then
					print(k, part)
				end
			end
		elseif not templates[v.inherits] then
			print(k, v.inherits)
		end
	end
end
-- AddOns\Blizzard_CharacterCreate\Blizzard_CharacterCreate.xml
--   CharacterCreateNavButtonTemplate, GlueButtonTemplate

local widgetObjects = {
	Frame = true,
	ArchaeologyDigSiteFrame = true,
	Browser = true,
	Button = true,
	CheckButton = true,
	Checkout = true,
	CinematicModel = true,
	ColorSelect = true,
	Cooldown = true,
	DressUpModel = true,
	EditBox = true,
	FogOfWarFrame = true,
	GameTooltip = true,
	ItemButton = true,
	MessageFrame = true,
	Model = true,
	ModelScene = true,
	MovieFrame = true,
	OffScreenFrame = true,
	PlayerModel = true,
	QuestPOIFrame = true,
	ScenarioPOIFrame = true,
	ScrollFrame = true,
	ScrollingMessageFrame = true,
	SimpleHTML = true,
	Slider = true,
	StatusBar = true,
	TabardModel = true,
	UnitPositionFrame = true,
	-- LayeredRegion
	Texture = true,
	Font = true,
	FontString = true,
	Line = true,

	AnimationGroup = true,
	Actor = true,
	FontFamily = true,
	-- intrinsics
	ContainedAlertFrame = true,
	DropDownToggleButton = true,
	EventFrame = true,
}

print("\n-- missing widget types:")
for k, v in pairs(templates) do
	if not widgetObjects[v.type] then
		print(k, v.type)
	end
end
-- AddOns\Blizzard_GuildControlUI\Blizzard_GuildControlUI.xml
--   GuildBankTabPermissionsTabTemplate (Button) is commented out

print("\n-- mixin not used in templates:")
local templateMixins = {}
for k, v in pairs(templates) do
	if v.mixin then
		if v.mixin:find(",") then
			for part in v.mixin:gmatch("[^%s,]+") do
				templateMixins[part] = true
			end
		else
			templateMixins[v.mixin] = true
		end
	end
end
for _, name in pairs(mixins) do
	if not templateMixins[name] then
		-- print(name)
	end
end

-- CovenantFollowerTabTemplate     GarrisonFollowerTabMixin,CovenantFollowerTabMixin
-- CovenantMissionListTemplate     GarrisonMissionListMixin, CovenantMissionListMixin
-- HorizontalLayoutFrame   LayoutMixin, HorizontalLayoutMixin
-- PropertyButtonTemplate  PropertyBindingMixin, PropertyButtonMixin
-- PropertyFontStringTemplate      PropertyBindingMixin, PropertyFontStringMixin  
-- PropertySliderTemplate  PropertyBindingMixin, PropertySliderMixin
-- VerticalLayoutFrame     LayoutMixin, VerticalLayoutMixin
-- WorldMapFrameTemplate   QuestLogOwnerMixin, WorldMapMixin

-- defined more than once
--BlackMarketColumnButtonTemplate -- first instance commented out
--Tutorial_PointerUp
--Tutorial_PointerDown
--Tutorial_PointerLeft
--Tutorial_PointerRight
--TutorialPointerFrame
--GameFontGreen
--GameFontHighlightLarge
--GameFontDisableLarge

-- templates are LoadOnDemand too
-- returns false for FontFamily (Font ObjectType)
-- they seem to just exist even if they are virtual
--[[
for k in pairs(Templates) do
	local exists = DoesTemplateExist(k)
	if not exists then
		print(k, DoesTemplateExist(k))
	end
end
]]

-- note there can be no space after a comma
--[[
["CovenantFollowerTabTemplate"] = {type = "Frame", mixin = "GarrisonFollowerTabMixin,CovenantFollowerTabMixin", inherits = "CovenantMissionBaseFrameTemplate"},
["FloatingChatFrameTemplate"] = {type = "ScrollingMessageFrame", inherits = "ChatFrameTemplate,FloatingBorderedFrame"},
["GarrisonFollowerTooltipTemplate"] = {type = "Frame", inherits = "GarrisonFollowerTooltipContentsTemplate,TooltipBorderedFrameTemplate"},
["PetBattleUnitTooltipTemplate"] = {type = "Frame", inherits = "PetBattleUnitFrameUnclickable,TooltipBorderedFrameTemplate"},
["SpellFlyoutButtonTemplate"] = {type = "CheckButton", inherits = "ActionButtonTemplate,SecureFrameTemplate"},
["UIPanelButtonNoTooltipResizeToFitTemplate"] = {type = "Button", mixin = "UIPanelButtonNoTooltipResizeToFitMixin", inherits = "UIPanelButtonNoTooltipTemplate,ResizeLayoutFrame"},
]]
