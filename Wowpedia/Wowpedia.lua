Wowpedia = {}
require("Wowpedia/MissingDocumentation")
require("Wowpedia/Functions")
require("Wowpedia/Events")
require("Wowpedia/Tables")
require("Wowpedia/ComplexType")
require("Wowpedia/FirstSeen")

local pageText = [[%s
%s
%s
<!-- ==Examples== -->
<!-- ==Patch changes== -->%s
<!-- ==See also== -->

==External Links==
{{subst:el}}
{{Elinks-api}}

==References==
{{Reflist|2}}
]]

function Wowpedia:GetPageText(apiTable)
	local template, desc, params, patch
	if apiTable.Type == "Function" then
		template = "{{wowapi}}"
		params = self:GetFunctionText(apiTable)
	elseif apiTable.Type == "Event" then
		template = string.format("{{wowapievent|%s}}", apiTable.LiteralName)
		params = self:GetEventText(apiTable)
	end
	desc = self:GetDescription(apiTable) or "Needs summary."
	patch = self:GetPatchText(apiTable)
	return pageText:format(template, desc, params, patch)
end

function Wowpedia:GetDescription()
end

require("Wowpedia/Tests")
