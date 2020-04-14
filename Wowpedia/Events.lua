local variableFs = "; %s : %s"
local prototypeText = " %s\n\n"

function Wowpedia:GetEventText(event)
	local str = prototypeText:format(self:GetEventSummary(event))
	if func.Payload then
		str = format("%s==Payload==\n\n%s\n\n",str,self:GetPayload(event))
	end
	return str
end

function Wowpedia:GetEventSummary(event)
	local proto = ""
  proto = event.Name 
 	for i, arg in ipairs(event.Payload) do
		local name = arg.Name
    proto = (i==1) and format("%s : %s", proto, name) or format("%s, $%s", proto, name)
  end
	return proto
end

function Wowpedia:GetPayload(event)
	local argTbl = {}
	for i, arg in ipairs(event.Payload) do
		local formatType =  Wowpedia:GetApiType(arg)
		argTbl[i] = variableFs:format(arg.Name, formatType)
    if arg.Nilable then
			argTbl[i] = argTbl[i].." (optional)"
		end
	end
	return table.concat(argTbl, "\n")
end
