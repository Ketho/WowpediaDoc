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

local function GetWikiFunctions(findUndocumented)
	local apidocs = {}
	for _, func in ipairs(APIDocumentation.functions) do
		-- print(func:GetFullName(false, false))
		local baseName = GetFunctionName(func)
		local signature
		if func.Arguments then
			signature = Wowpedia:GetSignature(func, "Arguments")
		end
		apidocs[baseName] = signature or findUndocumented
	end
	local fs_noone = ': [[API %s|%s]]()'
	local fs_args = ': [[API %s|%s]](<span style="font-size:smaller; color:#ecbc2a">%s</span>)'
	for _, funcName in ipairs(data) do
		local str
		if apidocs[funcName] then
			str = fs_args:format(funcName, funcName, apidocs[funcName])
		else
			str = fs_noone:format(funcName, funcName)
			if findUndocumented then
				print(funcName)
			end
		end
		print(str)
	end
end

GetWikiFunctions(true)
-- : [[API C_AchievementInfo.IsValidAchievement|C_AchievementInfo.IsValidAchievement]](<span style="font-size:smaller; color:#ecbc2a">achievementId</span>)
