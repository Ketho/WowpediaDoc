local hasText = false

function Wowpedia:GetPatchText()
	if hasText then
		return "\nsome patch changes\n"
	else
		return ""
	end
end
