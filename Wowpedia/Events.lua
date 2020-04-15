local paramFs = ";%s : %s"
local prototypeText = " %s\n\n"

function Wowpedia:GetEventText(event)
	local str = prototypeText:format(self:GetEventPrototype(event))
	if event.Payload then
		str = string.format("%s==Payload==\n%s\n\n", str, self:GetEventPayload(event))
	end
	return str
end

function Wowpedia:GetEventPrototype(event)
	return event.LiteralName ..": "..event:GetPayloadString(false, false)
end

function Wowpedia:GetEventPayload(event)
	local paramTbl = {}
	for i, param in ipairs(event.Payload) do
		local formatType =  Wowpedia:GetApiType(param)
		paramTbl[i] = paramFs:format(param.Name, formatType)
		if param.Nilable then
			paramTbl[i] = paramTbl[i].." (nilable)"
		end
	end
	return table.concat(paramTbl, "\n")
end
