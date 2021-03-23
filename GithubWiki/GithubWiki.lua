local util = require "Util/Util"

local WIKI = "https://raw.githubusercontent.com/wiki/Stanzilla/WoWUIBugs/9.0.1-Consolidated-UI-Changes.md"
local PATH = "GithubWiki/GithubWiki.md"

local apiTypes = {
	Functions = "Function",
	Events = "Event",
	Enums = "Enumeration",
	Structures = "Structure",
	["Frame Methods"] = "Method",
	["Script Handlers"] = "Script",
}

local fileTbl = util:DownloadAndRead(PATH, WIKI)

local descTbl = {}
local apiType

for idx, line in pairs(fileTbl) do
	if line:find("^### ") then
		apiType = line:match("### (.*)")
	elseif line:find("^#### ") then
		local name = line:match("#### (.*)")
		name = name:match("%[(.-)%].-") or name
		name = name:match("(.-)[%(%s].-") or name
		local desc = fileTbl[idx+1]
		if not desc:find("^Unknown") then
			descTbl[name] = {
				type = apiTypes[apiType],
				desc = desc,
			}
		end
	end
end

return descTbl
