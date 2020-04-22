function Wowpedia:GetEventText(event)
	local proto = string.format(" %s\n", self:GetEventPrototype(event))
	local payload = string.format("\n==Payload==\n%s\n", self:GetEventPayload(event))
	return proto..payload
end

function Wowpedia:GetEventPrototype(event)
	return event.LiteralName..(event.Payload and ": "..self:GetPrototypeString(event, "Payload") or "")
end

function Wowpedia:GetEventPayload(event)
	return event.Payload and self:GetParameters(event.Payload) or "None"
end
