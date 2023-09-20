-- https://wowpedia.fandom.com/wiki/Template:Restrictedapi
local m = {}

local levels = {
	protected = "This can only be called from [[secure code]].",
	hwevent = "This requires a hardware event i.e. keyboard/mouse input.",
	nocombat = "This cannot be called while in combat.",
	noinstance = "This only works outdoors and not in instanced content (dungeons/raids/battlegrounds/arena).",
	noscript = "This cannot be called ''directly'' from [[MACRO_script|/script]], [[API_loadstring|loadstring]] and WeakAuras.",
	grouponly = "This can only be queried on units in your party or raid.",
	secureframe = "This cannot be called on secure frames during combat; see [[SecureStateDriver]].",
	restrictedframe = "This cannot be called on [https://us.forums.blizzard.com/en/wow/t/ui-changes-in-rise-of-azshara/202487 restricted frames] e.g. nameplates. ([[Object_security#Anchor_restricted_regions|Object security]])",
	anchorfamily = "Frames that are anchored to a [https://us.forums.blizzard.com/en/wow/t/ui-changes-in-rise-of-azshara/202487 restricted frame] can only have their other anchors set to frames within that same anchor hierarchy. ([[Object_security#Anchor_restricted_regions|Object security]])",
	nopermission = "[[UI_ERROR_MESSAGE]]: <code>You do not have permission to perform that function</code>",
	nofreetrial = "This is not available to Free Trial / non-subscriber accounts.",

}

-- https://stackoverflow.com/a/7615129/1297035
local function strsplit(input, sep)
	local t = {}
	for s in string.gmatch(input, "([^"..sep.."]+)") do
		table.insert(t, s)
	end
	return t
end

local function contains(tbl, value)
	for _, v in pairs(tbl) do
		if value == v then
			return true
		end
	end
end

local function GetInfoText(f, protectedTypes)
	local t = {}
	for _, v in pairs(protectedTypes) do
		if levels[v] then
			local tag = string.format("'''<font color=\"#dda0dd\"><code>#%s</code></font>'''", v)
			table.insert(t, string.format("%s - %s", tag, levels[v]))
		end
	end
	-- tried {{{1}}} but then it wouldnt support formatted text fonts
	if #f.args.note > 0 then
		-- table.insert(t, string.rep("&nbsp;", 4)..f.args.info)
		table.insert(t, f.args.note)
	end
	return table.concat(t, "<br>")
end

local unrestrictedAmbox = {
	title = "Ambox",
	args = {
		border = "green",
		type = "'''This function appears to not require HW events.'''",
		image = "[[Image:Inv_misc_toy_10.png|32px|link=]]",
	}
}

local deprecatedAmbox = {
	title = "Ambox",
	args = {
		border = "yellow",
		type = "'''This function is deprecated.'''",
		image = "[[Image:Spell_holy_borrowedtime.png|32px|link=]]",
	}
}

local function GetAmbox(f)
	local protectedTypes = strsplit(f.args.type, ",")
	if contains(protectedTypes, "unrestricted") then
		return f:expandTemplate(unrestrictedAmbox)
	elseif contains(protectedTypes, "deprecated") then
		if #f.args.note > 0 then
			deprecatedAmbox.args.info = f.args.note
		else
			deprecatedAmbox.args.info = "It no longer appears to do anything."
		end
		return f:expandTemplate(deprecatedAmbox)
	end
	local template = {
		title = "Ambox",
		args = {
			border = "blue",
			type = "'''This function is [[:Category:API functions/restricted|restricted]].'''",
			style = "width: auto; margin-left: 0.8em;",
			info = GetInfoText(f, protectedTypes),
		}
	}
	if contains(protectedTypes, "protected") then
		template.args.image = [=[<div style="position: relative; padding: 0 5px 2px 0">[[Image:Icon-terminal.svg|48px|link=]]<div style="position:absolute; bottom: 0; right: 0">[[File:Ambox padlock red.svg|32px|link=]]</div></div>]=]
	elseif #f.args.icon > 0 then
		template.args.image = string.format("[[File:%s.png|link=]]", f.args.icon)
	else
		template.args.image = "[[File:Icon-addon-48x48.png|link=]]"
	end
	return f:expandTemplate(template)
end

-- local function GetCategories(f)
-- 	local t = {}
-- 	local cats = strsplit(f.args.type, ",")
-- 	for _, v in pairs(cats) do
-- 		table.insert(t, string.format("[[Category:API functions/restricted/%s]]", v))
-- 	end
-- 	return table.concat(t)
-- end

function m.main(f)
	return GetAmbox(f)
end

return m
