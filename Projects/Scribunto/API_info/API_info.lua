-- https://wowpedia.fandom.com/wiki/Module:API_info
-- https://github.com/Ketho/WowpediaApiDoc/blob/master/Projects/Scribunto/API_info/API_info.lua
local bit = require "bit32"
local flavor_data = mw.loadData("Module:API_info/flavor")
local elink_module = require("Module:API_info/elink")
local m = {}

-- show bcc before classic_era
local icons = {
	{id = 0x1, label = "[[File:Shadowlands-Logo-Small.png|34px|link=]] retail"},
	{id = 0x4, label = "[[File:Bc icon.gif|link=]]&nbsp; bcc"},
	{id = 0x2, label = "[[File:WoW Icon update.png|link=]] classic_era"},
}

-- mimicks [[Template:apinav]
local boxPattern = [=[
{| class="darktable nomobile" style="min-width:142px; float:right; clear:right;"
! Game [[Global_functions/Classic|Flavors]]
|-
| %s
|-
! Links
|-
| %s
|}
]=]

local multipleApi = {
	["API C BattleNet.GetAccountInfoByID"] = true,
	["API C BattleNet.GetGameAccountInfoByID"] = true,
	["API C ChatInfo.GetChannelRuleset"] = true,
	["API C ChatInfo.GetChannelShortcut"] = true,
	["API C ChatInfo.IsChannelRegional"] = true,
	["API C ChatInfo.SendAddonMessage"] = true,
	["API C Commentator.GetTeamColor"] = true,
	["API C CurrencyInfo.GetCurrencyInfo"] = true,
	["API C EncounterJournal.GetLootInfo"] = true,
	["API C FriendList.GetFriendInfo"] = true,
	["API C Item.DoesItemExist"] = true,
	["API C Item.GetItemIcon"] = true,
	["API C Item.GetItemInventoryType"] = true,
	["API C Item.GetItemName"] = true,
	["API C Item.GetItemQuality"] = true,
	["API C Item.IsItemDataCached"] = true,
	["API C Item.LockItem"] = true,
	["API C Item.RequestLoadItemData"] = true,
	["API C Item.UnlockItem"] = true,
	["API C LossOfControl.GetActiveLossOfControlData"] = true,
	["API C LossOfControl.GetActiveLossOfControlDataCount"] = true,
	["API C Map.GetUserWaypoint"] = true,
	["API C MountJournal.GetMountInfoByID"] = true,
	["API C ReportSystem.SetPendingReportTarget"] = true,
	["API C Scenario.GetCriteriaInfo"] = true,
	["API C Soulbinds.GetConduitCollectionData"] = true,
	["API GetAchievementCriteriaInfo"] = true,
	["API GetSpecializationInfo"] = true,
	["API GetTalentInfo"] = true,
	["API GetUnitPowerBarInfo"] = true,
	["API GetUnitPowerBarStrings"] = true,
	["API GetUnitPowerBarTextureInfo"] = true,
	["API SetPVP"] = true,
	["API UnitAura"] = true,
	["API UnitClass"] = true,
	["COMBAT LOG EVENT"] = true,
}

local function GetInfobox(name, flavors)
	local t = {}
	for _, v in pairs(icons) do
		if bit.band(flavors, v.id) > 0 then
			table.insert(t, v.label)
		end
	end
	local flavorText = table.concat(t, "<br>")
	local blizzdocText = elink_module.GetElinks(name)
	return boxPattern:format(flavorText, blizzdocText)
end

function m.main(f)
	local PAGENAME = f.args[1]
	local name = PAGENAME:gsub("API ", "")
	name = name:gsub(" ", "_")
	local flavors = flavor_data[name]
	if flavors and not multipleApi[PAGENAME] then
		local infobox = GetInfobox(name, flavors)
		return infobox
	end
end

return m
