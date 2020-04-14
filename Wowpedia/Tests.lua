-- no unit tests yet
local function DumpApiList(apiType)
	local apiTable = APIDocumentation:GetAPITableByTypeName(apiType)
	for i, apiInfo in ipairs(apiTable) do
		print(i, apiInfo.Name)
	end
end
--DumpApiList("system")


local function TestFunction(name)
	for i = 1, #APIDocumentation.functions do
		local func = APIDocumentation.functions[i]
		if func.Name == name then
			print(Wowpedia:GetPageText(func))
			break
		end
	end
end

-- TestFunction("GetItemKeyInfo")
-- TestFunction("IsGUIDBattleNetAccountType")


local function TestTable(name)
	local apiTable = Wowpedia.complexTypes[name]
	print(Wowpedia:GetTableLink(apiTable, "template"))
	print(Wowpedia:GetTableLink(apiTable, "caption"))
	print(Wowpedia:GetTableText(apiTable))
end

-- enums
-- TestTable("WidgetShownState")

-- structures
-- TestTable("AuctionHouseTimeLeftBand")
-- TestTable("BidInfo")


local function CountTableKeys(tbl)
	local count = 0
	for _ in pairs(tbl) do
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
	print("\namount of unique complex types (via Fields):", CountTableKeys(uniqueTypes)) -- 285
	print("amount of unique complex types (via Tables):", CountTableKeys(Wowpedia.complexTypes)) -- 361
	print("amount of unique referenced types (via Fields):", CountTableKeys(referencedTypes)) -- 237
	print("amount of unknown types (via Fields):", CountTableKeys(missingTypes)) -- 7
end
-- GetComplexTypeStats()
