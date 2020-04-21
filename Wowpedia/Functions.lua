function Wowpedia:GetFunctionText(func)
	local str = string.format(" %s\n", self:GetFunctionPrototype(func))
	if func.Arguments then
		str = str..string.format("\n==Arguments==\n%s\n", self:GetParameters(func.Arguments, true))
	end
	if func.Returns then
		str = str..string.format("\n==Returns==\n%s\n", self:GetParameters(func.Returns))
	end
	return str
end

function Wowpedia:GetFunctionPrototype(func)
	local str
	if func.System.Namespace then
		str = string.format("%s.%s", func.System.Namespace, func.Name)
	else
		str = func.Name
	end
	if func.Arguments then
		local argumentString = self:GetArgumentString(func)
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

function Wowpedia:GetArgumentString(func)
	local str, optionalFound
	for i, arg in ipairs(func.Arguments) do
		local name = arg.Name
		-- usually everything after the first optional argument is also optional
		if arg:IsOptional() and not optionalFound then
			optionalFound = true
			name = "["..name
		end
		str = (i==1) and name or str..", "..name
	end
	return optionalFound and str:gsub(", %[", " [, ").."]" or str
end
