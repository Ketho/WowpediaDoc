local variableFs = ";%s : %s"
local prototypeText = " %s\n\n"

function Wowpedia:GetFunctionText(func)
	local str = prototypeText:format(self:GetPrototype(func))
	if func.Arguments then
		str = format("%s==Arguments==\n%s\n\n",str,self:GetArguments(func))
	end
	if func.Returns then
		str = format("%s==Returns==\n%s\n\n",str,self:GetReturns(func))
	end
	return str.."<!-- \n==Triggers Events== -->"
end

function Wowpedia:GetPrototype(func)
	local proto = ""
	if func.System.Namespace then
		proto = string.format("%s.%s", func.System.Namespace, func.Name)
	else
		proto = func.Name
	end
	if func.Arguments then
		local argumentString = self:GetArgumentString(func)
		proto = string.format("%s(%s)", proto, argumentString)
	else
		proto = proto.."()"
	end
	if func.Returns then
		local returnString = func:GetReturnString(false, false) or ""
		proto = string.format("%s = %s", returnString, proto)
	end
	return proto
end

function Wowpedia:GetArguments(func)
	local argTbl = {}
	for i, arg in ipairs(func.Arguments) do
		local formatType =  Wowpedia:GetApiType(arg)
		argTbl[i] = variableFs:format(arg.Name, formatType)
		if arg.Default ~= nil then
			argTbl[i] = argTbl[i].." (optional, default = "..tostring(arg.Default)..")"
		elseif arg.Nilable then
			argTbl[i] = argTbl[i].." (optional)"
		end
	end
	return table.concat(argTbl, "\n")
end

function Wowpedia:GetArgumentString(func)
	local str, optionalFound
	for i, arg in ipairs(func.Arguments) do
		if i==1
			if arg:IsOptional() then
				str = string.format("[%s", arg.Name)
				optionalFound = true
			else
				str = arg.Name
			end
		else
			if arg:IsOptional() and not optionalFound then
				str = string.format("%s[, %s", str, arg.Name)
				optionalFound = true
			else
				str = string.format("%s, %s", str, arg.Name)
			end
		end
	end
	return optionalFound and str.."]" or str or ""
end

function Wowpedia:GetReturns(func)
	local retTbl = {}
	for i, ret in ipairs(func.Returns) do
		local formatType =  Wowpedia:GetApiType(ret)
		retTbl[i] = variableFs:format(ret.Name, formatType)
		if ret.Default ~= nil then
			retTbl[i] = retTbl[i].." (default = "..tostring(ret.Default)..")"
		elseif ret.Nilable then
			retTbl[i] = retTbl[i].." (nilable)"
		end
	end
	return table.concat(retTbl, "\n")
end

function Wowpedia:GetStrideIndexText()
end
