local hasText = false

function Wowpedia:GetPatchText()
	if hasText then
		return "\n==Patch changes==\n* some changes\n"
	end
end
