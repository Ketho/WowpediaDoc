local lfs = require "lfs"
local cURL = require "cURL"
local https = require "ssl.https"

local Util = {}

local CACHE_INVALIDATION_TIME = 600

Util.RelativePath = {
	["."] = true,
	[".."] = true,
}

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

function Util:CacheFile(path, url)
	local attr = lfs.attributes(path)
	if not attr or os.time() > attr.modification + CACHE_INVALIDATION_TIME then
		local body = https.request(url)
		self:WriteFile(path, body)
	end
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

function Util:WriteFile(path, text)
	print("Writing", path)
	local file = io.open(path, "w")
	file:write(text)
	file:close()
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

function Util:SortTable(tbl, func)
	local t = {}
	for k in pairs(tbl) do
		table.insert(t, k)
	end
	table.sort(t, func)
	return t
end

function Util.Sort_Nocase(a, b)
	return a:lower() < b:lower()
end

function Util:Wipe(tbl)
	for k in pairs(tbl) do
		tbl[k] = nil
	end
end

function Util:CopyTable(tbl)
	local t = {}
	for k, v in pairs(tbl) do
		t[k] = v
	end
	return t
end

function Util:GetFullName(apiTable)
	local fullName
	if apiTable.System.Namespace then
		fullName = format("%s.%s", apiTable.System.Namespace, apiTable.Name)
	else
		fullName = apiTable.Name
	end
	return fullName
end

--- combines table keys
---@vararg string
---@return table
function Util:CombineTable(...)
	local t = {}
	for i = 1, select("#", ...) do
		local tbl = select(i, ...)
		for k in pairs(tbl) do
			t[k] = true
		end
	end
	return t
end

function Util:GetPatchVersion(v)
	return v:match("%d+%.%d+%.%d+")
end

return Util
