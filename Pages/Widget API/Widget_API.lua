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
	Object = "abstract class",
	FrameScriptObject = "abstract class, inherits <code>Object</code>",
	ScriptRegion = "abstract class, inherits <code>FrameScriptObject</code>",
	Region = "abstract class, inherits <code>ScriptRegion</code>",
	TextureBase = "abstract class, inherits <code>Region</code>",
	Texture = "inherits <code>TextureBase</code>",
	MaskTexture = "inherits <code>TextureBase</code>",
	Line = "inherits <code>TextureBase</code>",
	Font = "inherits <code>Object</code>",
	FontString = "inherits <code>Region</code>",
	AnimationGroup = "inherits <code>FrameScriptObject</code>",
	Animation = "inherits <code>FrameScriptObject</code>",
	Alpha = "inherits <code>Animation</code>",
	Rotation = "inherits <code>Animation</code>",
	Scale = "inherits <code>Animation</code>",
	LineScale = "inherits <code>Animation</code>",
	Translation = "inherits <code>Animation</code>",
	LineTranslation = "inherits <code>Animation</code>",
	TextureCoordTranslation = "can only be created via XML, inherits <code>Animation</code>",
	FlipBook = "inherits <code>Animation</code>",
	Path = "inherits <code>Animation</code>",
	ControlPoint = "inherits <code>FrameScriptObject</code>",
	Frame = "inherits <code>ScriptRegion</code>",
	Button = "inherits <code>Frame</code>",
	CheckButton = "inherits <code>Button</code>",
	Model = "inherits <code>Frame</code>",
	ColorSelect = "inherits <code>Frame</code>",
	Cooldown = "inherits <code>Frame</code>",
	EditBox = "inherits <code>Frame</code>",
	MessageFrame = "inherits <code>Frame</code>",
	Minimap = "unique, inherits <code>Frame</code>",
	MovieFrame = "inherits <code>Frame</code>",
	ScrollFrame = "inherits <code>Frame</code>",
	SimpleHTML = "inherits <code>Frame</code>",
	Slider = "inherits <code>Frame</code>",
	StatusBar = "inherits <code>Frame</code>",
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
		for _, param in pairs(params) do
			local nilable = (param.Default or param.Default == false) or param.Nilable
			local name = string.format("%s%s", param.Name, nilable and "?" or "")
			table.insert(t, name)
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
