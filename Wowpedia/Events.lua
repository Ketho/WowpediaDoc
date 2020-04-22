function Wowpedia:GetEventText(event)
	local str = string.format(" %s\n", self:GetEventPrototype(event))
	if event.Payload then
		str = str..string.format("\n==Payload==\n%s\n", self:GetParameters(event.Payload))
	end
	return str
end

function Wowpedia:GetEventPrototype(event)
	return event.LiteralName ..": "..event:GetPayloadString(false, false)
end

function Wowpedia:GetEventPayload(event)
	return self:GetParameters(event.Payload)
end
