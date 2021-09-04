local Util = require("Util/Util")

Util:MakeDir("out")
Util:MakeDir("out/export")
local m = {}

local function WriteFile(path, text)
	--print("Writing", path)
	local file = io.open(path, "w")
	file:write(text)
	file:close()
end

function m:ExportSystems(folder)
	Util:MakeDir(format("%s/system", folder))
	for _, system in ipairs(APIDocumentation.systems) do
		print("Exporting", system:GetFullName())
		local systemName = system.Namespace or system.Name
		if systemName then
			Util:MakeDir(format("%s/system/%s", folder, systemName))
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
	Util:MakeDir(format("%s/enum", folder))
	Util:MakeDir(format("%s/struct", folder))
	print("Exporting (systemless) tables")
	for _, apiTable in ipairs(APIDocumentation.tables) do
		local isTransclude = Wowpedia.complexRefs[apiTable.Name]
		if isTransclude and isTransclude > 1 then
			local transcludeBase, shortType = Wowpedia:GetTranscludeBase(apiTable)
			local path = format("%s/%s/%s.txt", folder, shortType, transcludeBase)
			local pageText = Wowpedia:GetTableText(apiTable, true)
			WriteFile(path, pageText)
		end
	end
	print("Finished exporting")
end

return m
