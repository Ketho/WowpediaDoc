local lfs = require "lfs"
local cURL = require "cURL"

local Util = {}

function Util:DownloadFile(path, url)
	local file = io.open(path, "w")
	cURL.easy{
			url = url,
			writefunction = file,
			ssl_verifypeer = false,
		}:perform()
	:close()
	file:close()
end

function Util:ReadFile(path)
	local t = {}
	local file = io.open(path, "r")
	for line in file:lines() do
		table.insert(t, line)
	end
	file:close()
	return t
end

function Util:DownloadAndRead(path, url)
	self:DownloadFile(path, url)
	local t = self:ReadFile(path)
	return t
end

function Util:MakeDir(path)
	if not lfs.attributes(path) then
		lfs.mkdir(path)
	end
end

function Util:ToMap(tbl)
	local t = {}
	for _, v in pairs(tbl) do
		t[v] = true
	end
	return t
end

return Util
