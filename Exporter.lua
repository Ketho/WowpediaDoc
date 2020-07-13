local m = {}

local function WriteFile(path, text)
	-- print("Writing", path)
	local file = io.open(path, "w")
	file:write(text)
	file:close()
end

function m:ExportSystems(folder)
	os.execute(format("mkdir %s\\system", folder))
	for _, system in ipairs(APIDocumentation.systems) do
		print("Exporting", system:GetFullName())
		local systemName = system.Namespace or system.Name
		if systemName then
			os.execute(format("mkdir %s\\system\\%s", folder, systemName))
			local prefix = system.Namespace and system.Namespace.."." or ""
			for _, func in ipairs(system.Functions) do
				local path = format("%s/system/%s/API %s.txt", folder, systemName, prefix..func.Name)
				local pageText = Wowpedia:GetPageText(func)
				WriteFile(path, pageText)
			end
			for _, event in ipairs(system.Events) do
				local path = format("%s/system/%s/%s.txt", folder, systemName, event.LiteralName)
				local pageText = Wowpedia:GetPageText(event)
				WriteFile(path, pageText)
			end
		end
	end
	os.execute(format("mkdir %s\\enum", folder))
	os.execute(format("mkdir %s\\struct", folder))
	print("Exporting (systemless) tables")
	for _, apiTable in ipairs(APIDocumentation.tables) do
		local isTransclude = Wowpedia.complexRefs[apiTable.Name]
		local isSubtable = Wowpedia.subTables[apiTable.Name]
		if isTransclude and isTransclude > 1 or isSubtable then
			local transcludeBase, shortType = Wowpedia:GetTranscludeBase(apiTable)
			local path = format("%s/%s/%s.txt", folder, shortType, transcludeBase)
			local pageText = Wowpedia:GetTableText(apiTable, true)
			WriteFile(path, pageText)
		end
	end
	print("Finished exporting!")
end

return m
