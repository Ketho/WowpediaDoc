local tooltip_module = require("Module:Apitooltip")
local data = mw.loadData("Module:API_info/cvar/data")
local m = {}
local fs_tooltip = '<span class="tttemplatelink">%s</span><span style="display:none">%s</span>'

local function GetCVarInfo(name, info)
	-- cannot use unpack()
	local default, category, account, character, help = info[1], info[2], info[3], info[4], info[5]
	local t = {
		name = name,
		default = #default > 0 and default or "",
		cat = category ~= 5 and tostring(category) or "",
		scope = account and "Account" or character and "Character" or "",
		desc = #help > 0 and help or ""
	}
	return t
end

function m.GetTooltip(name)
	local info = data[1].var[name]
	if info then
		local source = GetCVarInfo(name, info)
		return fs_tooltip:format(tooltip_module.GetCVar(source))
	end
end

return m
