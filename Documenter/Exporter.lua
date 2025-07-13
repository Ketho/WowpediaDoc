local Util = require("util")
local Widgets = require("Documenter.Wowpedia.Widgets")
local log = require("util/log")

Util:MakeDir("out")
Util:MakeDir("out/export")
local m = {}

local function WriteFile(path, text)
	--print("Writing", path)
	local file = io.open(path, "w")
	if not file then return end -- uhh callback types are still unsupported
	file:write(text)
	file:close()
end

function m:ExportSystems(folder)
	Util:MakeDir(format("%s/system", folder))
	Util:MakeDir(format("%s/widget", folder))
	for _, system in ipairs(APIDocumentation.systems) do
		local systemFolder
		if system.Type == "System" then
			systemFolder = "system"
		elseif system.Type == "ScriptObject" then
			systemFolder = "widget"
		end
		log:info("Exporting system: "..system:GetFullName())
		local systemName = system.Name or system.Namespace
		if systemName then
			Util:MakeDir(format("%s/%s/%s", folder, systemFolder, systemName))
			local prefix
			if system.Type == "ScriptObject" then
				-- if not Widgets.widget_docs[system.Name] then print(system.Name) end
				prefix = Widgets.widget_docs[system.Name].." "
			else
				prefix = system.Namespace and system.Namespace.."." or ""
			end
			for _, func in ipairs(system.Functions) do
				local path = format("%s/%s/%s/API %s.txt", folder, systemFolder, systemName, prefix..func.Name)
				local pageText = Wowpedia:GetPageText(func, system.Type)
				WriteFile(path, pageText)
			end
			for _, event in ipairs(system.Events) do
				local path = format("%s/%s/%s/%s.txt", folder, systemFolder, systemName, event.LiteralName)
				local pageText = Wowpedia:GetPageText(event)
				WriteFile(path, pageText)
			end
		end
	end
	Util:MakeDir(format("%s/enum", folder))
	Util:MakeDir(format("%s/struct", folder))
	log:info("Exporting (systemless) tables")
	for _, apiTable in ipairs(APIDocumentation.tables) do
		local isTransclude = Wowpedia.complexRefs[apiTable.Name]
		if isTransclude and isTransclude > 1 then
			local transcludeBase, shortType = Wowpedia:GetTranscludeBase(apiTable)
			local path = format("%s/%s/%s.txt", folder, shortType:lower(), transcludeBase)
			local pageText = Wowpedia:GetTableText(apiTable, true)
			WriteFile(path, pageText)
		end
	end
	log:success("Finished exporting")
end

return m
