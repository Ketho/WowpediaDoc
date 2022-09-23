local Util = require("Util/Util")
local FrameXML = require("Documenter/Load_APIDocumentation/Loader")
FrameXML:LoadDocs("Documenter/Load_APIDocumentation")
require "Documenter/Wowpedia/Wowpedia"

local m = {}
local RETURN_MAX_LENGTH = 60

-- ugh this looks really ugly
local function TrimReturnString(s)
	local pos = 1
	local lastpos
	while true do
		lastpos = pos
		pos = s:find(",", pos)
		if pos then
			pos = pos + 1
			if pos > RETURN_MAX_LENGTH then
				break
			end
		else
			pos = lastpos
			break
		end
	end
	return s:sub(1, pos-2)..", ..."
end

function m:GetSignatures()
	local t = {}
	local fs_base = '[[API %s|%s]](%s)%s'
	local fs_args = '<span class="apiarg">%s</span>'
	local fs_returns = ' : <span class="apiret">%s</span>'
	for _, func in ipairs(APIDocumentation.functions) do
		local name = Util:GetFullName(func)
		local args, returns = "", ""
		if func.Arguments then
			args = fs_args:format(Wowpedia:GetSignature(func, "Arguments"))
		end
		if func.Returns then
			local returnString = func:GetReturnString(false, false)
			if #returnString > RETURN_MAX_LENGTH then
				local shortRetStr = TrimReturnString(returnString)
				returns = fs_returns:format(shortRetStr)
			else
				returns = fs_returns:format(returnString)
			end
		end
		t[name] = fs_base:format(name, name, args, returns)
	end
	return t
end

return m
