Wowpedia = {}
require("Wowpedia/Functions")
require("Wowpedia/Events")
require("Wowpedia/Tables")
require("Wowpedia/ComplexType")
require("Wowpedia/FirstSeen")

local pageText = [[%s
%s
%s<!-- 
==Examples== -->
%s<!-- 
==See also== -->

==External Links==
{{subst:el}}
{{Elinks-api}}
%s
]]

function Wowpedia:GetPageText(apiTable)
	local template, desc, params, patch, ref
	if apiTable.Type == "Function" then
		template = "{{wowapi}}"
		params = self:GetFunctionText(apiTable)
	elseif apiTable.Type == "Event" then
		template = string.format("{{wowapievent|%s}}", apiTable.LiteralName)
		params = self:GetEventText(apiTable)
	end
	desc = self:GetDescription(apiTable) or "Needs summary."
	patch = self:GetPatchText(apiTable) or "<!-- ==Patch changes== -->"
	ref = self:GetPatchText(apiTable) and "\n==References==\n{{Reflist|2}}" or "<!-- \n==References==\n{{Reflist|2}}\n-->"
	return pageText:format(template, desc, params, patch, ref)
end

function Wowpedia:GetDescription()
end

require("Wowpedia/Tests")
