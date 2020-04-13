Wowpedia = {}
require("Wowpedia/Functions")
require("Wowpedia/Events")
require("Wowpedia/Tables")
require("Wowpedia/ComplexType")
require("Wowpedia/FirstSeen")

local pageText = [=[%s
%s
%s
<!-- == Examples == -->
%s
<!-- == See also == -->
== External Links ==
{{subst:el}}
{{Elinks-api}}

== References ==
{{Reflist|2}}
]=]

function Wowpedia:GetPageText(apiTable)
	local header, description, body, footer
	if apiTable.Type == "Function" then
		header = "{{wowapi}}"
		body = self:GetFunctionText(apiTable)
	elseif apiTable.Type == "Event" then
		header = string.format("{{wowapievent|%s}}", apiTable.LiteralName)
		body = self:GetEventText(apiTable)	
	end
	description = self:GetDescription(apiTable) or "Needs summary."
	footer = "" -- footer = self:FirstSeen() and self:GetPatchText(apiTable) or "<!-- Needs populating -->"
	return pageText:format(header, description, body, footer)
end

for i = 1, #APIDocumentation.functions do
	local func = APIDocumentation.functions[i]
	if func.Name == "QueryBids" then
		print(Wowpedia:GetPageText(func))
	end
end
