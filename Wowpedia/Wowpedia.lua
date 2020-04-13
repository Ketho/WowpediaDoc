Wowpedia = {}
require("Wowpedia/Functions")
require("Wowpedia/ComplexType")

local pageText = "{{wowapi}}\nNeeds summary.\n%s"

function Wowpedia:GetPageText(obj)
	local objText
	if obj.Type == "Function" then
		objText = self:GetFunctionText(obj)
	end
	return pageText:format(objText)
end

for i = 1, #APIDocumentation.functions do
	local func = APIDocumentation.functions[i]
	if func.Name == "GetItemKeyFromItem" then
		print(Wowpedia:GetPageText(func))
	end
end
