require("Wowpedia/Functions")
require("Wowpedia/ComplexType")

local wowpediaText = "{{wowapi}}\nNeeds summary.\n%s"

function GetWowpediaText(obj)
	local objText
	if obj.Type == "Function" then
		objText = GetFunctionText(obj)
	end
	return wowpediaText:format(objText)
end

for i = 1, #APIDocumentation.functions do
	local func = APIDocumentation.functions[i]
	if func.Name == "GetItemKeyFromItem" then
		print(GetWowpediaText(func))
	end
end
