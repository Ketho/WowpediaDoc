local variableFs = ";%s : %s"
local functionText = " %s\n\n==Arguments==\n%s\n\n==Returns==\n%s"

function Wowpedia:GetArgumentString(func)
	local str = ""
	for i, arg in ipairs(func.Arguments) do
		local name = arg.Name
		if arg.Default or arg.Nilable then
			name = string.format("[%s]", arg.Name)
		end
		str = (i == 1) and name or str..", "..name
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
	if func.Arguments then
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
end

function Wowpedia:GetReturns(func)
	if func.Returns then
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
end

function Wowpedia:GetFunctionText(func)
	local proto = self:GetPrototype(func)
	local arguments = self:GetArguments(func)
	local returns = self:GetReturns(func)
	return functionText:format(proto, arguments, returns)
end
