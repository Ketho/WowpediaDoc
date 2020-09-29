local cURL = require "cURL"

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

local function DownloadFile(path, url)
	local file = io.open(path, "w")
	cURL.easy{
			url = url,
			writefunction = file,
			ssl_verifypeer = false,
		}:perform()
	:close()
	file:close()
end

local function ReadFile(path)
	local t = {}
	local file = io.open(path, "r")
	for line in file:lines() do
		table.insert(t, line)
	end
	file:close()
	return t
end

DownloadFile(PATH, WIKI)
local fileTbl = ReadFile(PATH)

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
