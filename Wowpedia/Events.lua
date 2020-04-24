function Wowpedia:GetEventText(event)
	local signature = format(" %s\n", self:GetEventSignature(event))
	local payload = format("\n==Payload==\n%s\n", self:GetEventPayload(event))
	return signature..payload
end

function Wowpedia:GetEventSignature(event)
	return event.LiteralName..(event.Payload and ": "..self:GetSignature(event, "Payload") or "")
end

function Wowpedia:GetEventPayload(event)
	return event.Payload and self:GetParameters(event.Payload) or "None"
end
