local prototypeText = " %s\n\n"

function Wowpedia:GetFunctionText(func)
	local str = prototypeText:format(self:GetFunctionPrototype(func))
	if func.Arguments then
		str = string.format("%s==Arguments==\n%s\n\n", str, self:GetParameters(func.Arguments))
	end
	if func.Returns then
		str = string.format("%s==Returns==\n%s\n\n", str, self:GetParameters(func.Returns))
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
		local argumentString = self:GetArgumentString(func) or ""
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
