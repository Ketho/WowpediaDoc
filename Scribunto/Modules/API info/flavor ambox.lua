local flavor_module = require("Module:API_info/flavor")
local patch_module = require("Module:API_info/patch")
local group_module = require("Module:API_info/group")
local m = {}

local info = {
	vanilla = {
		border = "yellow",
		image = "[[File:WoW Classic logo.png|128px|Classic Era|link=]]",
	},
	wrath = {
		border = "blue",
		image = "[[File:WoW Wrath Classic logo.png|80px|Wrath Classic|link=]]",
	},
	none = {
		border = "red",
		image = "[[File:Inv mushroom 11.png|32px|shroom|link=]]",
		type = "'''This no longer exists on any flavor of the game.'''",
	}
}

function m:GetAmbox(f, name)
	local flags, mainline, vanilla, wrath = flavor_module:GetFlavorInfo(f.args.t, name)
	local added = patch_module:GetPatches(f.args.t, name)
	-- dont show ambox when group infobox is already shown
	if #added > 0 and not group_module:GetData(name) then
		local template = {title = "Ambox"}
		if (vanilla or wrath) and not mainline then
			template.args = info[wrath and "wrath" or vanilla and "vanilla"]
			local expansions = {}
			if wrath then
				table.insert(expansions, "''[[World of Warcraft: Wrath of the Lich King Classic|Wrath Classic]]''")
			end
			if vanilla then
				table.insert(expansions, "''[[World of Warcraft: Classic|Classic Era]]''")
			end
			template.args.type = string.format("'''This API only exists in %s.'''", table.concat(expansions, " and "))
		elseif not flags then
			template.args = info.none
		end
		if template.args then
			template.args.style = "width: auto; margin-left: 0.8em;"
			local expanded = f:expandTemplate(template)
			if template.args == info.none then
				expanded = "[[Category:API functions/Noflavor]]\n"..expanded
			end
			return expanded
		end
	end
end

return m
