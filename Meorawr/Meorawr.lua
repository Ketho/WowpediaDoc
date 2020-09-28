local cURL = require "cURL"

local WIKI = "https://raw.githubusercontent.com/wiki/Stanzilla/WoWUIBugs/9.0.1-Consolidated-UI-Changes.md"
local PATH = "Meorawr/Meorawr.md"

local function HTTP_GET(url, file)
	cURL.easy{
		url = url,
		writefunction = file,
		ssl_verifypeer = false,
	}:perform():close()
end

-- write file, fill table
local f_write = io.open(PATH, "w")
HTTP_GET(WIKI, f_write)
f_write:close()

local f_tbl = {}
local f_read = io.open(PATH, "r")
for line in f_read:lines() do
    table.insert(f_tbl, line)
end
f_read:close()

-- probably not the best way to parse this
-- i have no idea what im doing
local function GetDescriptions()
    local t = {}
    for idx, line in pairs(f_tbl) do
        if line:find("#### ") then
            local header = line:match("#### (.*)")
            header = header:match("%[(.-)%].-") or header
            header = header:match("(.-)[%(%s].-") or header
            table.insert(t, {header, f_tbl[idx+1]})
        end
    end
    return t
end

for _, tbl in pairs(GetDescriptions()) do
    print(tbl[1])
    print(tbl[2])
end
