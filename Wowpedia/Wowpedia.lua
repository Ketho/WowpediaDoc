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
	local template, intro, body, patch
	if apiTable.Type == "Function" then
		template = "{{wowapi}}"
		body = self:GetFunctionText(apiTable)
	elseif apiTable.Type == "Event" then
		template = string.format("{{wowapievent|%s}}", apiTable.LiteralName)
		body = self:GetEventText(apiTable)	
	end
	intro = self:GetDescription(apiTable) or "Needs summary."
	patch = self:GetPatchText(apiTable) or "<!-- == Patch changes -->"
	return pageText:format(template, intro, body, patch)
end

for i = 1, #APIDocumentation.functions do
	local func = APIDocumentation.functions[i]
	if func.Name == "QueryBids" then
		print(Wowpedia:GetPageText(func))
	end
end
