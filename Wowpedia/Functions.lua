local paramFs = ";%s : %s"
local prototypeText = " %s\n\n"

function Wowpedia:GetFunctionText(func)
	local str = prototypeText:format(self:GetFunctionPrototype(func))
	if func.Arguments then
		str = string.format("%s==Arguments==\n%s\n\n", str, self:GetFunctionArguments(func))
	end
	if func.Returns then
		str = string.format("%s==Returns==\n%s\n\n", str, self:GetFunctionReturns(func))
	end
	return str.."<!-- \n==Triggers Events== -->"
end

function Wowpedia:GetFunctionPrototype(func)
	local proto
	if func.System.Namespace then
		proto = string.format("%s.%s", func.System.Namespace, func.Name)
	else
		proto = func.Name
	end
	if func.Arguments then
		local argumentString = self:GetFunctionArgumentString(func)
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

function Wowpedia:GetFunctionArguments(func)
	local argTbl = {}
	for i, arg in ipairs(func.Arguments) do
		local formatType = self:GetApiTypeByTable(arg)
		argTbl[i] = paramFs:format(arg.Name, formatType)
		if arg.Default ~= nil then
			argTbl[i] = argTbl[i].." (optional, default = "..tostring(arg.Default)..")"
		elseif arg.Nilable then
			argTbl[i] = argTbl[i].." (optional)"
		end
	end
	return table.concat(argTbl, "\n")
end

function Wowpedia:GetFunctionArgumentString(func)
	local str = ""
	for i, arg in ipairs(func.Arguments) do
		local name = arg.Name
		if arg:IsOptional() then
			name = string.format("[%s]", arg.Name)
		end
		str = (i==1) and name or str..", "..name
	end
	return str
end

function Wowpedia:GetFunctionReturns(func)
	local retTbl = {}
	for i, ret in ipairs(func.Returns) do
		local formatType = self:GetApiTypeByTable(ret)
		retTbl[i] = paramFs:format(ret.Name, formatType)
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
