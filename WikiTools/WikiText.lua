local WikiText = {}

local FrameXML = require("FrameXML/FrameXML")
FrameXML:LoadApiDocs("FrameXML")
require "Wowpedia/Wowpedia"
local data = require "WikiTools/Data"

local function GetFullName(func)
	local str
	if func.System.Namespace then
		str = format("%s.%s", func.System.Namespace, func.Name)
	else
		str = func.Name
	end
	return str
end

function WikiText:GetSignatures()
	local t = {}
	local fs_base = ': [[API %s|%s]](%s)%s'
	local fs_args = '<span style="font-size:smaller; color:#ecbc2a">%s</span>'
	local fs_returns = " : <span style=\"font-size:smaller; color:#4ec9b0\">%s</span>"
	for _, func in ipairs(APIDocumentation.functions) do
		local name = GetFullName(func)
		local args, returns = "", ""
		if func.Arguments then
			args = fs_args:format(Wowpedia:GetSignature(func, "Arguments"))
		end
		if func.Returns then
			returns = fs_returns:format(func:GetReturnString(false, false))
		end
		t[name] = fs_base:format(name, name, args, returns)
	end
	return t
end

return WikiText
