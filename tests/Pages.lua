local function TestFunction(name)
	for _, func in ipairs(APIDocumentation.functions) do
		-- print(func:GetFullName(false, false))
		local fullName
		if func.System.Namespace then
			fullName = format("%s.%s", func.System.Namespace, func.Name)
		else
			fullName = func.Name
		end
		if fullName == name then
			print(Wowpedia:GetPageText(func))
			break
		end
	end
end

-- TestFunction("C_Calendar.CanSendInvite") -- no arguments, one return value
-- TestFunction("C_Calendar.EventSetTitle") -- one argument, no return values
-- TestFunction("C_AuctionHouse.MakeItemKey") -- three optional args
-- TestFunction("C_Calendar.EventSetClubId") -- first argument optional
-- TestFunction("C_ArtifactUI.GetAppearanceInfo") -- two optional returns
-- TestFunction("C_Club.CreateClub") -- optional arguments in middle

-- TestFunction("C_ChatInfo.SendAddonMessage") -- string arguments
-- TestFunction("UnitPowerDisplayMod") -- enum transclude argument
-- TestFunction("C_Calendar.GetClubCalendarEvents") -- structure transclude arguments
-- TestFunction("C_AccountInfo.IsGUIDBattleNetAccountType") -- bool return
-- TestFunction("C_AuctionHouse.GetItemKeyInfo") -- struct inline returns
-- TestFunction("C_ActionBar.FindFlyoutActionButtons") -- number[] return
-- TestFunction("C_AuctionHouse.GetTimeLeftBandInfo") -- transclude argument
-- TestFunction("C_CovenantSanctumUI.GetSanctumType") -- inline enum return

-- TestFunction("C_AreaPoiInfo.GetAreaPOISecondsLeft") -- documentation
-- TestFunction("C_ArtifactUI.GetEquippedArtifactNumRelicSlots") -- argument documentation
-- TestFunction("C_ArtifactUI.GetMetaPowerInfo") -- StrideIndex
-- TestFunction("C_MapExplorationInfo.GetExploredMapTextures") -- structure in structure

-- TestFunction("C_Map.GetMapInfo") -- incongruent system name and namespace
-- TestFunction("GetUnitPowerBarInfo") -- no system namespace


local function TestEvent(name)
	for _, event in ipairs(APIDocumentation.events) do
		-- print(event:GetFullName(false, false))
		if event.LiteralName == name then
			print(Wowpedia:GetPageText(event))
			break
		end
	end
end

-- TestEvent("ACTIONBAR_SHOWGRID") -- no payload
-- TestEvent("ITEM_SEARCH_RESULTS_UPDATED") -- struct, nilable
-- TestEvent("TRACKED_ACHIEVEMENT_UPDATE") -- optional params
-- TestEvent("AUCTION_HOUSE_AUCTION_CREATED") -- documentation
-- TestEvent("CLUB_MESSAGE_HISTORY_RECEIVED") -- documentation in payload
-- TestEvent("CONTRIBUTION_CHANGED") -- StrideIndex
-- TestEvent("HONOR_XP_UPDATE") -- Unit system

local function TestTable(name)
	local apiTable = Wowpedia.complexTypes[name]
	-- print(Wowpedia:GetTableTransclude(apiTable))
	print(Wowpedia:GetTableText(apiTable, true))
end

-- enums
-- TestTable("UIWidgetVisualizationType")
-- TestTable("AuctionHouseTimeLeftBand") -- anonymous system
-- TestTable("PowerType") -- Unit system

-- structures
-- TestTable("BidInfo") -- struct and enum
-- TestTable("ArtifactArtInfo") -- mixins
-- TestTable("ItemKey") -- nilable, default
-- TestTable("AuctionHouseBrowseQuery") -- innertype enum
-- TestTable("ItemSearchResultInfo") -- innertype string
-- TestTable("ItemKeyInfo") -- nilable, bool
-- TestTable("ClubMessageIdentifier") -- documentation in field
-- TestTable("QuestWatchConsts") -- constants

-- missing
-- TestTable("CalendarTime")
-- TestTable("AppearanceSourceInfo")
-- TestTable("GuildTabardInfo")

local function PrintWowpediaLinks(name)
	local fsFunc = ": {{api|%s}}"
	local fsEvent = ": {{api|t=e|%s}}"
	for _, system in ipairs(APIDocumentation.systems) do
		if (system.Namespace or system.Name) == name then
			for _, func in ipairs(system.Functions) do
				print(fsFunc:format(func.Name))
			end
			for _, event in ipairs(system.Events) do
				print(fsEvent:format(event.LiteralName))
			end
			break
		end
	end
end
-- PrintWowpediaLinks("Unit")
-- PrintWowpediaLinks("Expansion")
