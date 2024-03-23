import requests
import pywikibot
import os
import time
from pathlib import Path

site = pywikibot.Site("en", "warcraftwiki")
url = 'https://warcraft.wiki.gg'

redirects = [
	#  api
	"API C ArtifactUI.GetPowersAffectedByRelicItemLink",
	"API C ArtifactUI.GetRelicInfoByItemID",
	"API C AzeriteEmpoweredItem.GetAllTierInfoByItemID",
	"API C AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID",
	"API C AzeriteItem.IsAzeriteItemByID",
	"API C BattleNet.GetAccountInfoByGUID",
	"API C BattleNet.GetAccountInfoByID",
	"API C BattleNet.GetGameAccountInfoByGUID",
	"API C BattleNet.GetGameAccountInfoByID",
	"API C Calendar.EventRemoveInviteByGuid",
	"API C ChatInfo.GetChannelRulesetForChannelID",
	"API C ChatInfo.GetChannelShortcutForChannelID",
	"API C ChatInfo.IsChannelRegionalForChannelID",
	"API C ChatInfo.SendAddonMessageLogged",
	"API C ClubFinder.GetRecruitingClubInfoFromFinderGUID",
	"API C Commentator.GetTeamColorByUnit",
	"API C ConfigurationWarnings.GetConfigurationWarnings",
	"API C ConfigurationWarnings.GetConfigurationWarningSeen",
	"API C ConfigurationWarnings.GetConfigurationWarningString",
	"API C ConfigurationWarnings.SetConfigurationWarningSeen",
	"API C CurrencyInfo.GetCurrencyInfoFromLink",
	"API C DateAndTime.AdjustTimeByMinutes",
	"API C EncounterJournal.GetLootInfoByIndex",
	"API C FriendList.GetFriendInfoByIndex",
	"API C Item.DoesItemExistByID",
	"API C Item.GetItemIconByID",
	"API C Item.GetItemInventoryTypeByID",
	"API C Item.GetItemNameByID",
	"API C Item.GetItemQualityByID",
	"API C Item.IsItemDataCachedByID",
	"API C Item.LockItemByGUID",
	"API C Item.RequestLoadItemDataByID",
	"API C Item.UnlockItemByGUID",
	"API C LossOfControl.GetActiveLossOfControlDataByUnit",
	"API C LossOfControl.GetActiveLossOfControlDataCountByUnit",
	"API C Map.GetUserWaypointFromHyperlink",
	"API C MountJournal.GetDisplayedMountAllCreatureDisplayInfo",
	"API C MountJournal.GetDisplayedMountInfo",
	"API C MountJournal.GetDisplayedMountInfoExtra",
	"API C PvP.GetScoreInfoByPlayerGuid",
	"API C Soulbinds.GetConduitCollectionDataAtCursor",
	"API C Soulbinds.GetConduitCollectionDataByVirtualID",
	"API C TaskQuest.GetQuestTimeLeftMinutes",
	"API C Timer.NewTicker",
	"API C TransmogSets.SetHasNewSourcesForSlot",
	"API IsAltKeyDown",
	"API IsControlKeyDown",
	"API IsLeftAltKeyDown",
	"API IsLeftControlKeyDown",
	"API IsLeftShiftKeyDown",
	"API IsRightAltKeyDown",
	"API IsRightControlKeyDown",
	"API IsRightShiftKeyDown",
	"API IsShiftKeyDown",
	"API GetSpecializationInfoForClassID",
	"API GetSpecializationInfoForSpecID",
	"API GetUnitPowerBarInfoByID",
	"API GetUnitPowerBarStringsByID",
	"API GetUnitPowerBarTextureInfoByID",
	"API UnitClassBase",
	"API ToggleCollision",
	"API ToggleCollisionDisplay",
	"API TogglePlayerBounds",
	"API TogglePortals",
	"API ToggleTris",
	"API GetNormalizedRealmName",
	"API UnitFullName",
	"API UnitNameUnmodified",
	# events
	"RAID ROSTER UPDATE",
	"PVP MATCH STATE CHANGED",
	"WARGAME INVITE SENT",
	"WARGAME REQUEST RESPONSE",
	"RUNE TYPE UPDATE",
	"UNIT MANA",
	# structs
	"Struct FriendInfo",
	"Struct PVPScoreInfo",
	"Struct RafReward",
	"Struct UiMapPoint",
]

def category_members(catname):
	params = {
		'action': 'query',
		'list': 'categorymembers',
		'cmtitle': f'Category:{catname}',
		'cmlimit': 'max',
		'format': 'json',
		'formatversion': 2,
	}
	while True:
		resp = requests.post(f'{url}/api.php', params)
		data = resp.json()
		for page in data['query']['categorymembers']:
			yield page
		if data.get('continue'):
			params.update(data['continue'])
		else:
			break

def getFileText(p):
	f = open(p)
	lines = f.readlines()
	return "".join(lines)
	
def recursiveFiles(path, l):
	for base in os.listdir(path):
		newPath = Path(path, base)
		if os.path.isdir(newPath):
			if base != "widget":
				recursiveFiles(newPath, l)
		else:
			name = base[:-4].replace("_", " ")
			l.update({name: getFileText(newPath)})

def get_documented_api():
	fullpath = Path("out", "export")
	l = {}
	recursiveFiles(fullpath, l)
	return l

def main():
	# apiPages = ([ page['title'] for page in category_members('API functions') ])
	catNames = [
		'API functions',
		'API events',
		'Widget methods',
		'Structs',
		'Enums',
	]
	cats = []
	for v in catNames:
		for member in category_members(v):
			cats.append(member['title'])

	docApi = get_documented_api()
	for v in docApi:
		if not v in cats and not v in redirects:
			print(v)
			page = pywikibot.Page(site, v)
			if not page.exists():
				page.text = docApi[v]
				page.save(summary="up to 10.2.6")
				time.sleep(5)
	print("done")

if __name__ == "__main__":
	main()
