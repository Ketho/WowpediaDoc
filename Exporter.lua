local function WriteFile(path, text)
	print("writing:", path)
	local file = io.open(path, "w")
	file:write(text)
	file:close()
end

function ExportSystem(systemName)
	for _, system in ipairs(APIDocumentation.systems) do
		if system.Namespace == systemName then
			local namespace = system.Namespace or system.Name
			local prefix = namespace and namespace.."." or ""
			for _, func in pairs(system.Functions) do
				local path = format("out/API %s.txt", prefix..func.Name)
				local pageText = Wowpedia:GetPageText(func)
				WriteFile(path, pageText)
			end
			for _, event in pairs(system.Events) do
				local path = format("out/%s.txt", event.LiteralName)
				local pageText = Wowpedia:GetPageText(event)
				WriteFile(path, pageText)
			end
			for _, apiTable in pairs(system.Tables) do
				local isTransclude = Wowpedia.complexRefs[apiTable.Name] > 1
				if isTransclude then
					local transcludeBase = Wowpedia:GetTranscludeBase(apiTable)
					local path = format("out/%s.txt", transcludeBase)
					local pageText = Wowpedia:GetTableText(apiTable, true)
					 WriteFile(path, pageText)
				end
			end
		end
	end
end
