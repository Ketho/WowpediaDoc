function Wowpedia:GetFunctionText(func)
	local str = string.format(" %s\n", self:GetFunctionSignature(func))
	if func.Arguments then
		str = str..string.format("\n==Arguments==\n%s\n", self:GetParameters(func.Arguments, true))
	end
	if func.Returns then
		str = str..string.format("\n==Returns==\n%s\n", self:GetParameters(func.Returns))
	end
	return str
end

function Wowpedia:GetFunctionSignature(func)
	local str
	if func.System.Namespace then
		str = string.format("%s.%s", func.System.Namespace, func.Name)
	else
		str = func.Name
	end
	if func.Arguments then
		local argumentString = self:GetSignature(func, "Arguments")
		str = string.format("%s(%s)", str, argumentString)
	else
		str = str.."()"
	end
	if func.Returns then
		local returnString = func:GetReturnString(false, false)
		str = string.format("%s = %s", returnString, str)
	end
	return str
end
