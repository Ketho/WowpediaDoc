local proto = " %s\n\n"
local eventFs = "%s==Payload==\n%s\n\n"

function Wowpedia:GetEventText(event)
	local str = proto:format(self:GetEventPrototype(event))
	if event.Payload then
		str = string.format(eventFs, str, self:GetParameters(event.Payload))
	end
	return str
end

function Wowpedia:GetEventPrototype(event)
	return event.LiteralName ..": "..event:GetPayloadString(false, false)
end

function Wowpedia:GetEventPayload(event)
	return self:GetParameters(event.Payload)
end
