local lfs = require "lfs"
local Util = require("Util/Util")
local event_data = loadfile("out/lua/API_info.patch.event_retail.lua")()

local FRAMEXML = "FrameXML/retail"
local OUT = "out/lua/API_info.patch.event_retail_framexml.lua"

local skipDir = {
	["."] = true,
	[".."] = true,
}

local non_framexml_added = {
	UNIT_TARGET = "2.0.1",
}

local m = {}

-- sort eg 1.2.0 to be before 1.10.0
function m:GetPatches(path)
	local t = {}
	for folder in lfs.dir(path) do
		if not skipDir[folder] then
			table.insert(t, folder)
		end
	end
	-- sorting by build is easier in this case
	table.sort(t, function(a, b)
		local build_a = tonumber(a:match("%d+%.%d+%.%d+%.(%d+)"))
		local build_b = tonumber(b:match("%d+%.%d+%.%d+%.(%d+)"))
		if build_a ~= build_b then
			return build_a < build_b
		end
	end)
	return t
end

function m:GetEvents(patches, path)
	local t = {}
	for _, event in pairs(Util:SortTable(event_data)) do
		local v = event_data[event]
		if v[1] == false then
			for _, patch in pairs(patches) do
				local found = self:IterateFiles(path.."/"..patch, event)
				if found then
					print(event, (found:gsub(path.."/", "")))
					t[event] = found:match("%d+%.%d+%.%d+")
					break
				end
			end
		end
	end
	return t
end

function m:IterateFiles(folder, search)
	for fileName in lfs.dir(folder) do
		local path = folder.."/"..fileName
		local attr = lfs.attributes(path)
		if attr.mode == "directory" then
			if not skipDir[fileName] then
				local path2 = self:IterateFiles(path, search)
				if path2 then
					return path2
				end
			end
		else
			if fileName:find("%.lua") and fileName ~= "GlobalStrings.lua" then
				if self:ParseLua(path, search) then
					return path
				end
			end
		end
	end
end

function m:ParseLua(path, search)
	local file = io.open(path, "r")
	local text = file:read("a")
	return text:find(string.format('"%s"', search))
end

function m:CorrectData(tbl)
	for event, patch in pairs(non_framexml_added) do
		tbl[event] = patch
	end
end

function m:WriteData(tbl)
	local file = io.open(OUT, "w")
	file:write("local data = {\n")
	for _, event in pairs(Util:SortTable(tbl)) do
		local version = tbl[event]
		file:write(string.format('\t["%s"] = "%s",\n', event, version))
	end
	file:write("}\n\nreturn data\n")
end

function m:main()
	local patches = self:GetPatches(FRAMEXML)
	local eventData = self:GetEvents(patches, FRAMEXML)
	self:CorrectData(eventData)
	self:WriteData(eventData)
end

m:main()
print("done")

--[[
differences when matching with/without quotes
conclusion: use quotes

-- mismatch
ACHIEVEMENT_PLAYER_NAME: only in 5.0.4 helix as SCRIPT_ACHIEVEMENT_PLAYER_NAME; in 8.0.1 apidocs
CHANNEL_LEFT: false positive as BN_CHAT_CHANNEL_LEFT in 3.3.5; in 8.0.1 apidocs
CHAT_MSG_BN: false positive as CHAT_MSG_BN_CONVERSATION in 3.3.5; in 8.0.1 apidocs
CLASS_TRIAL_TIMER_START: false positive as EVENT_CLASS_TRIAL_TIMER_START in 7.0.3; in 8.0.1 apidocs
CLASS_TRIAL_UPGRADE_COMPLETE: false positive as EVENT_CLASS_TRIAL_UPGRADE_COMPLETE in 7.0.3; in 8.0.1 apidocs
TUTORIAL_HIGHLIGHT_SPELL: false positive as EVENT_TUTORIAL_HIGHLIGHT_SPELL in 7.0.3; in 8.0.1 apidocs
TUTORIAL_UNHIGHLIGHT_SPELL: false positive as EVENT_TUTORIAL_UNHIGHLIGHT_SPELL in 7.0.3; in 8.0.1 apidocs
UNIT_PET: false positive as UNIT_PET_EXPERIENCE in 1.1.2; in 1.5.0
UNIT_TARGET: false positive as UNIT_TARGETABLE_CHANGED in 4.0.1; in 5.4.0 helix and 6.0.2 framexml; in 2.0.1
UPDATE_SHAPESHIFT_FORM: false positive as UPDATE_SHAPESHIFT_FORMS in 1.0.0; in 2.0.1 framexml

-- same
CONFIRM_XP_LOSS: there is a globalstring with the same name; both 1.1.2
INSTANCE_LOCK_WARNING: there is a globalstring with the same name; both 4.0.1
LFG_OFFER_CONTINUE: there is a globalstring and staticpopup with the same name; both 3.3.0
LUA_WARNING: false positive as constant as LUA_WARNING_TREAT_AS_ERROR constant; both 5.4.2
PVP_BRAWL_INFO_UPDATED: mentioned in apidocs; both 7.2.0
READY_CHECK: false positive as READY_CHECK_MESSAGE; both 1.11.0
RESURRECT_REQUEST: false positive as RESURRECT_REQUEST_TIMER; both 1.1.2
TRANSMOG_COLLECTION_SOURCE_ADDED: mentioned in a comment; only in helix; both 7.1.0
TRANSMOG_COLLECTION_SOURCE_REMOVED: mentioned in a comment; only in helix; both 7.1.0
UNIT_AURA: false positive as UNIT_AURASTATE; both 1.1.2
]]
