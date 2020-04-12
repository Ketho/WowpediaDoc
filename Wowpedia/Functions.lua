local variableFs = ";%s : %s"

local function GetPrototype(func)
	local proto = ""
	if func.System.Namespace then
		proto = string.format("%s.%s", func.System.Namespace, func.Name)
	else
		proto = func.Name
	end
	if func.Arguments then
		local argumentString = func:GetArgumentString(false, false)
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

local function GetArguments(func)
	if func.Arguments then
		local argTbl = {}
		for i, arg in ipairs(func.Arguments) do
			argTbl[i] = variableFs:format(arg.Name, arg.Type)
		end
		return table.concat(argTbl, "\n")
	end
end

local function GetReturns(func)
	if func.Returns then
		local retTbl = {}
		for i, ret in ipairs(func.Returns) do
			retTbl[i] = variableFs:format(ret.Name, ret.Type)
		end
		return table.concat(retTbl, "\n")
	end
end

for i = 1, #APIDocumentation.functions do
	local func = APIDocumentation.functions[i]
	print("", "", i, GetPrototype(func))

	local arguments = GetArguments(func)
	if arguments then
		print("", "Arguments:")
		print(arguments)
	end

	local returns = GetReturns(func)
	if returns then
		print("", "Returns:")
		print(returns)
	end
end
