Wowpedia = {}
require("Wowpedia/Functions")
require("Wowpedia/Events")
require("Wowpedia/Tables")
require("Wowpedia/ComplexType")
require("Wowpedia/FirstSeen")

local pageText = "%s\nNeeds summary.\n%s"

function Wowpedia:GetPageText(apiTable)
	local template, str
	if apiTable.Type == "Function" then
		template = "{{wowapi}}"
		str = self:GetFunctionText(apiTable)
	elseif apiTable.Type == "Event" then
		template = string.format("{{wowapievent|%s}}", apiTable.LiteralName)
		str = self:GetEventText(apiTable)
	end
	return pageText:format(template, str)
end

for i = 1, #APIDocumentation.functions do
	local func = APIDocumentation.functions[i]
	if func.Name == "QueryBids" then
		print(Wowpedia:GetPageText(func))
	end
end
