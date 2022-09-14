local widgets = require("Documenter/Wowpedia/Widgets").widget_docs

function Wowpedia:GetFunctionText(func, systemType)
	local str = format(" %s\n", self:GetFunctionSignature(func, systemType))
	-- widget api can provide empty tables
	if func.Arguments and #func.Arguments>0 then
		str = str..format("\n==Arguments==\n%s\n", self:GetParameters(func.Arguments, true))
	end
	if func.Returns and #func.Returns>0 then
		str = str..format("\n==Returns==\n%s\n", self:GetParameters(func.Returns))
	end
	return str
end

function Wowpedia:GetFunctionSignature(func, systemType)
	local str
	if systemType == "ScriptObject" then
		str = format("%s:%s", widgets[func.System.Name], func.Name)
	elseif func.System.Namespace then
		str = format("%s.%s", func.System.Namespace, func.Name)
	else
		str = func.Name
	end
	if func.Arguments then
		local argumentString = self:GetSignature(func, "Arguments")
		str = format("%s(%s)", str, argumentString)
	else
		str = str.."()"
	end
	if func.Returns then
		local returnString = func:GetReturnString(false, false)
		str = format("%s = %s", returnString, str)
	end
	return str
end
