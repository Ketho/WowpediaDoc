-- no unit tests yet
local function DumpApiList(apiType)
	local apiTable = APIDocumentation:GetAPITableByTypeName(apiType)
	for i, apiInfo in ipairs(apiTable) do
		print(i, apiInfo.Name)
	end
end
-- DumpApiList("system")


local function TestFunction(name)
	for _, func in ipairs(APIDocumentation.functions) do
		if func.Name == name then
			print(Wowpedia:GetPageText(func))
			break
		end
	end
end

-- TestFunction("CanSendInvite") -- no arguments, one return value
-- TestFunction("EventSetTitle") -- one argument, no return values
-- TestFunction("MakeItemKey") -- three optional args
-- TestFunction("EventSetClubId") -- first argument optional
-- TestFunction("GetAppearanceInfo") -- two optional returns

-- TestFunction("SendAddonMessage") -- string arguments
-- TestFunction("UnitPowerDisplayMod") -- enum arguments
-- TestFunction("GetClubCalendarEvents") -- structure arguments
-- TestFunction("IsGUIDBattleNetAccountType") -- bool return
-- TestFunction("GetItemKeyInfo") -- struct returns
-- TestFunction("FindFlyoutActionButtons") -- number[] return
-- TestFunction("CreateClub") -- optionals in middle


local function TestEvent(name)
	for _, event in ipairs(APIDocumentation.events) do
		if event.LiteralName == name then
			print(Wowpedia:GetPageText(event))
			break
		end
	end
end

-- TestEvent("ACTIONBAR_SHOWGRID") -- no payload
-- TestEvent("ITEM_SEARCH_RESULTS_UPDATED") -- struct, nilable

local function TestTable(name)
	local apiTable = Wowpedia.complexTypes[name]
	print(Wowpedia:GetTableTemplate(apiTable))
	print(Wowpedia:GetTableCaption(apiTable))
	print(Wowpedia:GetTableText(apiTable))
end

-- enums
-- TestTable("AuctionHouseTimeLeftBand") -- anonymous system
-- TestTable("WidgetShownState")
-- TestTable("UIWidgetVisualizationType")
-- TestTable("PowerType")

-- structures
-- TestTable("BidInfo") -- struct and enum
-- TestTable("ArtifactArtInfo") -- mixins
-- TestTable("ItemKey") -- nilable, default
-- TestTable("AuctionHouseBrowseQuery") -- innertype enum
-- TestTable("ItemSearchResultInfo") -- innertype string
-- TestTable("ItemKeyInfo") -- nilable, bool

-- missing
-- TestTable("CalendarTime")
-- TestTable("AppearanceSourceInfo")
-- TestTable("GuildTabardInfo")


local function CountKeys(t)
	local count = 0
	for _ in pairs(t) do
		count = count + 1
	end
	return count
end

local function GetComplexTypeStats()
	-- why not use this anyway
	local knownTypes = CreateFromMixins(Wowpedia.basicTypes, Wowpedia.complexTypes)
	local uniqueTypes, missingTypes = {}, {}
	local referencedTypes = {}

	for _, field in pairs(APIDocumentation.fields) do
		-- find unique types
		if not Wowpedia.basicTypes[field.Type] then
			uniqueTypes[field.Type] = true
		end
		-- find missing types
		if not knownTypes[field.Type] then
			missingTypes[field.Type] = true
		end
		-- find amount of times types are referenced
		local parent = field.Function or field.Event or field.Table
		if not Wowpedia.basicTypes[field.Type] and parent.Type ~= "Enumeration" then
			referencedTypes[field.Type] = (referencedTypes[field.Type] or 0) + 1
		end
	end

	print("# undocumented types:")
	for name in pairs(missingTypes) do
		print(name)
	end

	-- todo: manually check types with refcount==2
	print("\n# referenced types:")
	for name, amount in pairs(referencedTypes) do
		if amount > 1 then
			print(amount, name)
		end
	end

	-- huh this is confusing
	print("\namount of unique complex types (via Fields):", CountKeys(uniqueTypes)) -- 285
	print("amount of unique complex types (via Tables):", CountKeys(Wowpedia.complexTypes)) -- 361
	print("amount of unique referenced types (via Fields):", CountKeys(referencedTypes)) -- 237
	print("amount of unknown types (via Fields):", CountKeys(missingTypes)) -- 7
end
-- GetComplexTypeStats()

-- APIDocumentation:HandleSlashCommand("stats")

-- CreateClub
-- GetInvitationCandidates
-- GetRuneforgeModifierInfo
-- BONUS_ROLL_RESULT
-- VOICE_CHAT_PENDING_CHANNEL_JOIN_STATE
-- ENTITLEMENT_DELIVERED
-- RAF_ENTITLEMENT_DELIVERED
local function GetSignaturesWithMiddleOptionals(apiType, paramTbl, apiName)
	for _, apiTable in ipairs(APIDocumentation[apiType]) do
		local optional
		if apiTable[paramTbl] then
			for _, param in ipairs(apiTable[paramTbl]) do
				if param.Nilable then
					optional = true
				else
					if optional then
						print(apiTable[apiName])
						break
					end
				end
			end
		end
	end
end
-- GetSignaturesWithMiddleOptionals("functions", "Arguments", "Name")
-- GetSignaturesWithMiddleOptionals("events", "Payload", "LiteralName")
