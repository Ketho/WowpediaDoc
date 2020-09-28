local cURL = require "cURL"

local WIKI = "https://raw.githubusercontent.com/wiki/Stanzilla/WoWUIBugs/9.0.1-Consolidated-UI-Changes.md"
local PATH = "GithubWiki/GithubWiki.md"

local function DownloadFile(path, url)
	local file = io.open(path, "w")
	cURL.easy{
		url = url,
		writefunction = file,
		ssl_verifypeer = false,
	}:perform():close()
	file:close()
end

local function LoadFile(path)
	local t = {}
	local file = io.open(path, "r")
	for line in file:lines() do
		table.insert(t, line)
	end
	file:close()
	return t
end

DownloadFile(PATH, WIKI)
local fileTbl = LoadFile(PATH)

local descTbl = {}
for idx, line in pairs(fileTbl) do
	if line:find("#### ") then
		local header = line:match("#### (.*)")
		header = header:match("%[(.-)%].-") or header
		header = header:match("(.-)[%(%s].-") or header
		table.insert(descTbl, {header, fileTbl[idx+1]})
	end
end

for _, tbl in pairs(descTbl) do
	print(tbl[1])
	print(tbl[2])
end
