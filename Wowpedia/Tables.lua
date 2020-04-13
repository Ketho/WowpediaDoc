
function Wowpedia:GetTableText(apiTable)
	if apiTable.Type == "Enumeration" then
		return self:GetEnumerationText(apiTable)
	elseif apiTable.Type == "Structure" then
		return self:GetEnumerationText(apiTable)
	end
end

function Wowpedia:GetEnumerationText()
end

function Wowpedia:GetStructureText()
end
