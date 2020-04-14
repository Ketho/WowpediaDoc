-- function page
for i = 1, #APIDocumentation.functions do
	local func = APIDocumentation.functions[i]
	if func.Name == "GetItemKeyInfo" then
		--print(Wowpedia:GetPageText(func))
	end
end

-- enum template
print(Wowpedia:GetTable("WidgetShownState"))
-- enum table
print(Wowpedia:GetTable("ItemInteractionFrameType"))
