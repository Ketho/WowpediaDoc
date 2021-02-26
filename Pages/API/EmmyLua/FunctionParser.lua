local WikiText = require "Pages/API/WikiText"
local signatures = WikiText:GetSignatures()

local file = io.open("Pages/API/World_of_Warcraft_API.txt", "r")
local newFile = io.open("Pages/API/World_of_Warcraft_API_arguments.txt", "w")
local api = {}

for line in file:lines() do
	if line:match("^: (.-)") then
		local name = line:match("%[%[API (.-)|")
		local args = line:match("ecbc2a\">(.-)</span>%)")
		--local returns = line:match("%) : (.+</span>)")
		if name and not signatures[name] and args then
			args = args:gsub("%s?%[", "")
			args = args:gsub("%]", "")
			local isValid = not args:find(" or ") and not args:find("|")
				and not args:find("-") and not args:find("%.%.%.") and not args:find("/")
			if isValid then
				newFile:write(format("%s; %s\n", name, args))
				api[name] = args
			end
		end
	end
end

file:close()
newFile:close()
print("done!")

return api

-- for some reason there are 4 documented
-- functions not on the wiki (1734/1738)
-- but I don't see anything wrong in MissingAPI.lua

-- weird usage errors:
-- Usage: GetItemInfo(itemID (, itemModID)|"name"|"itemlink") <- C_TransmogCollection.GetItemInfo()
-- Usage: SetGuildRecruitmentSettings(index, true/false)
-- Usage: DisableAddOn(index or "name", [set for all or "character"])
-- Usage: ChannelSetAllSilent([channelNumber | channelName], memberName, silenceOn)
-- Usage: GetBonusStepRewardQuestID(stepIndex
-- Usage: CollapseGuildTradeSkillHeader(trade skill ID)
-- Usage: IsGuildRankAssignmentAllowed(player index, rank index)
-- Usage: LearnTalents(talentID1 [, talentID2, ...])
-- Usage: SetCurrentGraphicsSetting(setting{0=normal, 1=raid/BG})
