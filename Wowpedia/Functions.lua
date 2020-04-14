local variableFs = ";%s : %s"
local prototypeText = " %s\n"

function Wowpedia:GetArgumentString(func)
	local str = ""
	for i, arg in ipairs(func.Arguments) do
		local name = arg.Name
		if arg.Default or arg.Nilable then
			name = string.format("[%s]", arg.Name)
		end
		str = (i==1) and name or str..", "..name
	end
	return str
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
		local formatType =  Wowpedia:GetType(arg)
		argTbl[i] = variableFs:format(arg.Name, formatType)
		if arg.Default ~= nil then
			argTbl[i] = argTbl[i].." (optional, default = "..tostring(arg.Default)..")"
		elseif arg.Nilable then
			argTbl[i] = argTbl[i].." (optional)"
		end
	end
	return table.concat(argTbl, "\n")
end

function Wowpedia:GetReturns(func)
	local retTbl = {}
	for i, ret in ipairs(func.Returns) do
		local formatType =  Wowpedia:GetType(ret)
		retTbl[i] = variableFs:format(ret.Name, formatType)
		if ret.Default ~= nil then
			retTbl[i] = retTbl[i].." (default = "..tostring(ret.Default)..")"
		elseif ret.Nilable then
			retTbl[i] = retTbl[i].." (nilable)"
		end
	end
	return table.concat(retTbl, "\n")
end

function Wowpedia:GetFunctionText(func)
	local str = prototypeText:format(self:GetPrototype(func))
	if func.Arguments then
		str = str.."\n==Arguments==\n"..self:GetArguments(func)
	end
	if func.Returns then
		str = func.Arguments and str.."\n" or str
		str = str.."\n==Returns==\n"..self:GetReturns(func)
	end
	return str.."\n\n<!-- ==Triggers Events== -->"
end
