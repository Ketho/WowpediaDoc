local function PrintDocumentation(apiType)
	for _, apiTable in ipairs(APIDocumentation[apiType]) do
		if apiTable.Documentation then
			if apiType == "fields" then
				local parent = apiTable.Function or apiTable.Event or apiTable.Table
				print(parent.Type, parent.Name, apiTable.Name, apiTable.Documentation[1])
			else
				print(apiTable.Name, apiTable.Documentation[1])
			end
		end
	end
end
-- PrintDocumentation("functions")
-- PrintDocumentation("events")
-- PrintDocumentation("fields")


local function FindSignaturesWithMiddleOptionals(apiType, paramTbl, apiName)
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
-- FindSignaturesWithMiddleOptionals("functions", "Arguments", "Name")
-- FindSignaturesWithMiddleOptionals("events", "Payload", "LiteralName")

-- CreateClub
-- GetInvitationCandidates
-- GetRuneforgeModifierInfo

-- BONUS_ROLL_RESULT
-- ENTITLEMENT_DELIVERED
-- RAF_ENTITLEMENT_DELIVERED
-- VOICE_CHAT_PENDING_CHANNEL_JOIN_STATE


local function FindUnusedTables()
	for _, system in ipairs(APIDocumentation.systems) do
		for _, apiTable in ipairs(system.Tables) do
			local isTransclude = Wowpedia.complexRefs[apiTable.Name]
			if not isTransclude then
				print(apiTable.Name)
			end
		end
	end
end
-- FindUnusedTables()

-- ClubFinderApplicationUpdateType
-- ClubFinderSettingFlags
-- ContributionAppearanceFlags
-- ItemTryOnReason
-- QuestTag
-- SuperTrackingType
-- TooltipSide
-- TooltipTextureAnchor
-- TooltipTextureRelativeRegion
-- TransmogSource
-- UIMapSystem
-- UiwIdgetFlag
-- WidgetCurrencyClass


local function FindMissingTables()
	local tbl = {}
	for _, field in ipairs(APIDocumentation.fields) do
		local apiType = field.InnerType or field.Type
		local isComplex = Wowpedia.complexTypes[apiType]
		if not Wowpedia.basicTypes[apiType] and not isComplex then
			tbl[apiType] = true
		end
	end
	for name in pairs(tbl) do
		print(name)
	end
end
-- FindMissingTables()

-- AppearanceSourceInfo
-- CalendarTime
-- GarrisonTalentTreeInfo
-- GuildTabardInfo
-- ItemLevelTier
-- OptionalReagentInfo
-- QueueSpecificInfo
-- RuneforgeLegendaryCraftDescription
-- RuneforgePower


local function FindFrameObjects()
	local tbl = {}
	for _, field in ipairs(APIDocumentation.fields) do
		if field.Type == "table" and not field.Mixin and not field.InnerType then
			local parent = field.Function or field.Event or field.Table
			print(parent.Name, field.Name)
		end
	end
end
-- FindFrameObjects()

-- SetPortraitTexture, textureObject
-- SetAvatarTexture, texture
-- GetFrame, frame
-- NavigationFrameCreated, region
-- GetUserWaypoint, point
-- GetUserWaypointFromHyperlink, point
-- SetUserWaypoint, point
-- ForbiddenNamePlateCreated, namePlateFrame
-- NamePlateCreated, namePlateFrame
-- AddActiveModelScene, modelSceneFrame
-- AddActiveModelSceneActor, modelSceneFrameActor
-- ClearActiveModelScene, modelSceneFrame
-- ClearActiveModelSceneActor, modelSceneFrameActor
-- SetPortraitTexture, textureObject
-- SetPortraitTextureFromCreatureDisplayID, textureObject
-- SetPortraitTexture, textureObject


local function FindIncongruentSystemNames()
	for _, system in ipairs(APIDocumentation.systems) do
		if system.Namespace then
			if system.Namespace:gsub("C_", "") ~= system.Name then
				print(system.Namespace, system.Name)
			end
		end
	end
end
-- FindIncongruentSystemNames()

-- C_AnimaDiversion, AnimaDiversionInfo
-- C_CVar, CVarScripts
-- C_ChallengeMode, ChallengeModeInfo
-- C_ChromieTime, ChromieTimeInfo
-- C_ClubFinder, ClubFinderInfo
-- C_Commentator, CommentatorFrame
-- C_CurrencyInfo, CurrencySystem
-- C_Garrison, GarrisonInfo
-- C_Navigation, InGameNavigation
-- C_ItemInteraction, ItemInteractionUI
-- C_Mail, MailInfo
-- C_Map, MapUI
-- C_MythicPlus, MythicPlusInfo
-- C_PetJournal, PetJournalInfo
-- C_PlayerInfo, PlayerLocationInfo
-- C_PvP, PvpInfo
-- C_QuestLine, QuestLineUI
-- C_TaskQuest, QuestTaskInfo
-- C_Reputation, ReputationInfo
-- C_Social, SocialInfo
-- C_SuperTrack, SuperTrackManager
-- C_System, SystemInfo
-- C_Texture, TextureUtils
-- C_Transmog, Transmogrify
-- C_TransmogCollection, Transmogrify
-- C_TransmogSets, Transmogrify
-- C_Macro, UIMacros
-- C_VideoOptions, Video
-- C_VignetteInfo, Vignette
-- C_CampaignInfo, WarCampaign
-- Expansion
-- Unit

-- some structures contain another complex type twice which should not be transcluded
local function FindDoubleUsedTable()
	for _, apiTable in ipairs(APIDocumentation.tables) do
		if apiTable.Type == "Structure" then
			local typeCount = {}
			for _, tbl in pairs(apiTable.Fields) do
				local tblType = tbl.InnerType or tbl.Type
				if not Wowpedia.basicTypes[tblType] then
					typeCount[tblType] = (typeCount[tblType] or 0) + 1
					local count = typeCount[tblType]
					if count > 1 and count == Wowpedia.complexRefs[tblType] then
						print(apiTable.Name, tblType, count)
					end
				end
			end
		end
	end
end
-- FindDoubleUsedTable()

-- RafInfo, RafReward, 2
-- ScriptedAnimationEffect, ScriptedAnimationBehavior, 2
-- DoubleStateIconRowVisualizationInfo, UIWidgetStateIconInfo, 2
