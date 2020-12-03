local cURL = require "cURL"
local util = {}

function util:DownloadFile(path, url)
	local file = io.open(path, "w")
	cURL.easy{
			url = url,
			writefunction = file,
			ssl_verifypeer = false,
		}:perform()
	:close()
	file:close()
end

function util:ReadFile(path)
	local t = {}
	local file = io.open(path, "r")
	for line in file:lines() do
		table.insert(t, line)
	end
	file:close()
	return t
end

function util:DownloadAndRead(path, url)
	self:DownloadFile(path, url)
	local t = self:ReadFile(path)
	return t
end

function util:ToMap(tbl)
	local t = {}
	for _, v in pairs(tbl) do
		t[v] = true
	end
	return t
end

return util
