local proto = " %s\n\n"

function Wowpedia:GetFunctionText(func)
	local str = proto:format(self:GetFunctionPrototype(func))
	if func.Arguments then
		str = string.format("%s==Arguments==\n%s\n\n", str, self:GetParameters(func.Arguments, true))
	end
	if func.Returns then
		str = string.format("%s==Returns==\n%s\n\n", str, self:GetParameters(func.Returns))
	end
	return str.."<!-- \n==Triggers Events== -->"
end

function Wowpedia:GetFunctionPrototype(func)
	local str
	if func.System.Namespace then
		str = string.format("%s.%s", func.System.Namespace, func.Name)
	else
		str = func.Name
	end
	if func.Arguments then
		local argumentString = self:GetArgumentString(func) or ""
		str = string.format("%s(%s)", str, argumentString)
	else
		str = str.."()"
	end
	if func.Returns then
		local returnString = func:GetReturnString(false, false) or ""
		str = string.format("%s = %s", returnString, str)
	end
	return str
end

function Wowpedia:GetArgumentString(func)
	local str, optionalFound
	for i, arg in ipairs(func.Arguments) do
		local name = arg.Name
		-- assume everything after the first optional argument is also optional
		if arg:IsOptional() and not optionalFound then
			optionalFound = true
			name = "["..name
		end
		str = (i==1) and name or str..", "..name
	end
	return optionalFound and str:gsub(", %[", " [, ").."]" or str
end

function Wowpedia:GetStrideIndexText()
end
