local cURL = require "cURL"

local WIKI = "https://raw.githubusercontent.com/wiki/Stanzilla/WoWUIBugs/9.0.1-Consolidated-UI-Changes.md"
local PATH = "Meorawr/Meorawr.md"

local function HTTP_GET(url, file)
	cURL.easy{
		url = url,
		writefunction = file,
		ssl_verifypeer = false,
		useragent = user_agent,
	}:perform():close()
end

local f_write = io.open(PATH, "w")
HTTP_GET(WIKI, f_write)
f_write:close()

local f_read = io.open(PATH, "r")
for line in f_read:lines() do
    print(line)
end
