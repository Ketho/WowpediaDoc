local Path = require "path"
local lfs = require "lfs"
local CONSTANTS = require("Documenter.constants")
local OUT = Path.join("out", "page", "Widget_API.txt")
local BRANCH = "mainline"

local widget_systems = {
	CooldownFrameAPI = "Cooldown",
	MinimapFrameAPI = "Minimap",
	SimpleAnimAPI = "Animation",
	SimpleAnimAlphaAPI = "Alpha",
	SimpleAnimFlipBookAPI = "FlipBook",
	SimpleAnimGroupAPI = "AnimationGroup",
	SimpleAnimPathAPI = "Path",
	SimpleAnimRotationAPI = "Rotation",
	SimpleAnimScaleAPI = "Scale",
	SimpleAnimScaleLineAPI = "LineScale", -- empty
	SimpleAnimTextureCoordTranslationAPI = "TextureCoordTranslation",
	SimpleAnimTranslationAPI = "Translation",
	SimpleAnimTranslationLineAPI = "LineTranslation", -- empty
	SimpleAnimatableObjectAPI = "AnimatableObject",
	-- SimpleBrowserAPI = "Browser",
	SimpleButtonAPI = "Button",
	SimpleCheckboxAPI = "CheckButton",
	SimpleColorSelectAPI = "ColorSelect",
	SimpleControlPointAPI = "ControlPoint",
	SimpleEditBoxAPI = "EditBox",
	SimpleFontAPI = "Font",
	SimpleFontStringAPI = "FontString",
	SimpleFrameAPI = "Frame",
	SimpleFrameScriptObjectAPI = "FrameScriptObject",
	SimpleHTMLAPI = "SimpleHTML",
	SimpleLineAPI = "Line",
	SimpleMaskTextureAPI = "MaskTexture", -- empty
	SimpleMessageFrameAPI = "MessageFrame",
	SimpleModelAPI = "Model",
	-- SimpleModelFFXAPI = "ModelFFX", -- unavailable to addons
	SimpleMovieAPI = "MovieFrame",
	SimpleObjectAPI = "Object",
	-- SimpleOffScreenFrameAPI = "OffScreenFrame",
	SimpleRegionAPI = "Region",
	SimpleScriptRegionAPI = "ScriptRegion",
	SimpleScriptRegionResizingAPI = "ScriptRegionResizing",
	SimpleScrollFrameAPI = "ScrollFrame",
	SimpleSliderAPI = "Slider",
	SimpleStatusBarAPI = "StatusBar",
	SimpleTextureAPI = "Texture",
	SimpleTextureBaseAPI = "TextureBase",
	-- ScriptRegionSharedDocumentation
	-- SharedScriptObjectModelLightDocumentation
}

local widget_order = {
	"Object",
	"FrameScriptObject",
	"ScriptRegion", "ScriptRegionResizing", "AnimatableObject",
	"Region",
	"TextureBase",
	"Texture", "MaskTexture", "Line",
	"Font",	"FontString",
	"AnimationGroup",
	"Animation",
	"Alpha",
	"Rotation",
	"Scale", "LineScale",
	"Translation", "LineTranslation",
	"TextureCoordTranslation",
	"FlipBook",
	"Path",	"ControlPoint",
	"Frame",
	"Button", "CheckButton",
	"Model",
	-- "PlayerModel", "CinematicModel", "DressUpModel", "TabardModel",
	-- ModelScene
	-- ModelSceneActor
	"ColorSelect",
	"Cooldown",
	"EditBox",
	-- GameTooltip
	"MessageFrame",
	"Minimap",
	"MovieFrame",
	"ScrollFrame",
	"SimpleHTML",
	"Slider",
	"StatusBar",
	-- ArchaeologyDigSiteFrame
	-- QuestPOIFrame
	-- ScenarioPOIFrame
	-- FogOfWarFrame
	-- UnitPositionFrame
	-- "Browser",
	-- Checkout
	-- "OffScreenFrame",
	-- WorldFrame
}

local widget_desc = {
	Object = 'abstract class',
	FrameScriptObject = 'inherits <code>Object</code>, abstract class',
	ScriptRegion = 'inherits <code>FrameScriptObject</code>, abstract class',
	Region = 'inherits <code>ScriptRegion</code>, abstract class',
	TextureBase = 'inherits <code>Region</code>, abstract class',
	Texture = 'inherits <code>TextureBase</code>, created with <code>Frame:CreateTexture()</code>',
	MaskTexture = 'inherits <code>TextureBase</code>, created with <code>Frame:CreateMaskTexture()</code>',
	Line = 'inherits <code>TextureBase</code>, created with <code>Frame:CreateLine()</code>',
	Font = 'inherits <code>Object</code>, created with <code>CreateFont(name)</code>',
	FontString = 'inherits <code>Region</code>, created with <code>Frame:CreateFontString()</code>',
	AnimationGroup = 'inherits <code>FrameScriptObject</code>, created with <code>AnimatableObject:CreateAnimationGroup()</code>',
	Animation = 'inherits <code>FrameScriptObject</code>, created with <code>AnimationGroup:CreateAnimation()</code>',
	Alpha = 'inherits <code>Animation</code>, created with <code>AnimationGroup:CreateAnimation("Alpha")</code>',
	Rotation = 'inherits <code>Animation</code>, created with <code>AnimationGroup:CreateAnimation("Rotation")</code>',
	Scale = 'inherits <code>Animation</code>, created with <code>AnimationGroup:CreateAnimation("Scale")</code>',
	LineScale = 'inherits <code>Animation</code>, created with <code>AnimationGroup:CreateAnimation("LineScale")</code>',
	Translation = 'inherits <code>Animation</code>, created with <code>AnimationGroup:CreateAnimation("Translation")</code>',
	LineTranslation = 'inherits <code>Animation</code>, created with <code>AnimationGroup:CreateAnimation("LineTranslation")</code>',
	TextureCoordTranslation = 'inherits <code>Animation</code>, can only be created via XML',
	FlipBook = 'inherits <code>Animation</code>, created with <code>AnimationGroup:CreateAnimation("FlipBook")</code>',
	Path = 'inherits <code>Animation</code>, created with <code>AnimationGroup:CreateAnimation("Path")</code>',
	ControlPoint = 'inherits <code>FrameScriptObject</code>, created with <code>Path:CreateControlPoint()</code>',
	Frame = 'inherits <code>ScriptRegion</code>, created with <code>{{api|CreateFrame}}("Frame")</code>',
	Button = 'inherits <code>Frame</code>, created with <code>CreateFrame("Button")</code>',
	CheckButton = 'inherits <code>Button</code>, created with <code>CreateFrame("CheckButton")</code>',
	Model = 'inherits <code>Frame</code>, created with <code>CreateFrame("Model")</code>',
	ColorSelect = 'inherits <code>Frame</code>, created with <code>CreateFrame("ColorSelect")</code>',
	Cooldown = 'inherits <code>Frame</code>, created with <code>CreateFrame("Cooldown")</code>',
	EditBox = 'inherits <code>Frame</code>, created with <code>CreateFrame("EditBox")</code>',
	MessageFrame = 'inherits <code>Frame</code>, created with <code>CreateFrame("MessageFrame")</code>',
	Minimap = 'inherits <code>Frame</code>, unique',
	MovieFrame = 'inherits <code>Frame</code>, created with <code>CreateFrame("MovieFrame")</code>',
	ScrollFrame = 'inherits <code>Frame</code>, created with <code>CreateFrame("ScrollFrame")</code>',
	SimpleHTML = 'inherits <code>Frame</code>, created with <code>CreateFrame("SimpleHTML")</code>',
	Slider = 'inherits <code>Frame</code>, created with <code>CreateFrame("Slider")</code>',
	StatusBar = 'inherits <code>Frame</code>, created with <code>CreateFrame("StatusBar")</code>',
}

local function GetSystems()
	local t = {}
	for _, system in pairs(APIDocumentation.systems) do
		local widget_name = widget_systems[system.Name]
		if widget_name then
			t[widget_name] = {}
			for _, func in pairs(system.Functions) do
				table.insert(t[widget_name], func)
			end
		end
	end
	return t
end

local function GetParams(params)
	if params and #params > 0 then
		local t = {}
		local hasStrideIndex
		for _, param in pairs(params) do
			local nilable = (param.Default or param.Default == false) or param.Nilable
			local name = string.format("%s%s", param.Name, nilable and "?" or "")
			if param.StrideIndex then
				hasStrideIndex = true
			end
			table.insert(t, name)
		end
		if hasStrideIndex then
			table.insert(t, "...")
		end
		return table.concat(t, ", ")
	end
end

local function GetTemplate(widget, func)
	local t = {}
	table.insert(t, "apilink")
	table.insert(t, "t=w")
	table.insert(t, string.format("%s:%s", widget, func.Name))
	local args = GetParams(func.Arguments)
	if args then
		table.insert(t, "arg="..args)
	end
	local rets = GetParams(func.Returns)
	if rets then
		table.insert(t, "ret="..rets)
	end
	return string.format("{{%s}}", table.concat(t, "|"))
end

local function main()
	require("Documenter.Load_APIDocumentation.Loader"):main(BRANCH)
	local systemInfo = GetSystems()
	local file = io.open(OUT, "w")
	print("writing to "..OUT)
	for _, widget in pairs(widget_order) do
		file:write(string.format("===%s===\n", widget))
		if widget_desc[widget] then
			file:write(widget_desc[widget].."\n")
		end
		for _, func in pairs(systemInfo[widget]) do
			local template = GetTemplate(widget, func)
			file:write(string.format(": %s\n", template))
		end
		file:write("\n")
	end
	file:close()
end

main()
print("done")
