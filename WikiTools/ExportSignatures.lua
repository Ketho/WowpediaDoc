-- this converts function names to wiki links with colored arguments
local FrameXML = require("FrameXML/FrameXML")
FrameXML:LoadApiDocs("FrameXML")
require "Wowpedia/Wowpedia"
local data = require "WikiTools/Data"

local function GetFunctionName(func)
	local str
	if func.System.Namespace then
		str = format("%s.%s", func.System.Namespace, func.Name)
	else
		str = func.Name
	end
	return str
end

local function GetWikiFunctions()
	local apidocs = {}
	for _, func in ipairs(APIDocumentation.functions) do
		-- print(func:GetFullName(false, false))
		local baseName = GetFunctionName(func)
		local args, returns
		if func.Arguments then
			args = Wowpedia:GetSignature(func, "Arguments")
		end
		if func.Returns then
			returns = func:GetReturnString(false, false)
		end
		apidocs[baseName] = {args, returns} -- findUndocumented
	end
	local fs_base = ': [[API %s|%s]](%s)%s'
	local fs_args = '<span style="font-size:smaller; color:#ecbc2a">%s</span>'
	local fs_returns = " : <span style=\"font-size:smaller; color:#4ec9b0\">%s</span>"
	for _, funcName in ipairs(data) do
		local str
		local argStr, retStr = "", ""
		if apidocs[funcName] then
			if apidocs[funcName][1] then
				argStr = fs_args:format(apidocs[funcName][1])
			end
			if apidocs[funcName][2] then
				retStr = fs_returns:format(apidocs[funcName][2])
			end
		end
		str = fs_base:format(funcName, funcName, argStr, retStr)
		-- if findUndocumented then
		-- 	print(funcName)
		-- end
		print(str)
	end
end

GetWikiFunctions()
-- : [[API C_AchievementInfo.IsValidAchievement|C_AchievementInfo.IsValidAchievement]](<span style="font-size:smaller; color:#ecbc2a">achievementId</span>)
