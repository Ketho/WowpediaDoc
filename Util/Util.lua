local lfs = require "lfs"
local cURL = require "cURL"
local https = require "ssl.https"
local ltn12 = require "ltn12"

local Util = {}

local INVALIDATION_TIME = 60*60

Util.RelativePath = {
	["."] = true,
	[".."] = true,
}

function Util:WriteFile(path, text)
	print("Writing", path)
	local file = io.open(path, "w")
	file:write(text)
	file:close()
end

function Util:DownloadFile(path, url)
	local file = io.open(path, "w")
	cURL.easy{
		url = url,
		writefunction = file,
		ssl_verifypeer = false,
	}:perform():close()
	file:close()
end

-- todo: replace with ShouldRedownload
function Util:CacheFile(path, url)
	local attr = lfs.attributes(path)
	if not attr or os.time() > attr.modification + INVALIDATION_TIME then
		local body = https.request(url)
		self:WriteFile(path, body)
	end
end

function Util:ShouldRedownload(path)
	local attr = lfs.attributes(path)
	if not attr or os.time() > attr.modification + INVALIDATION_TIME then
		return true
	end
end

-- https://github.com/brunoos/luasec/wiki/LuaSec-1.0.x#httpsrequesturl---body
function Util:HttpPostRequest(url, request)
	local response = {}
	local _, code = https.request{
		url = url,
		method = "POST",
		headers = {
			["Content-Length"] = string.len(request),
			["Content-Type"] = "application/x-www-form-urlencoded"
		},
		source = ltn12.source.string(request),
		sink = ltn12.sink.table(response)
	}
	if code == "200" then
		error("HTTP error: "..code)
	else
		return table.concat(response)
	end
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

function Util:SortTableCustom(tbl, func)
	local t = {}
	for k, v in pairs(tbl) do
		table.insert(t, {
			key = k,
			value = v
		})
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

-- https://stackoverflow.com/a/7615129/1297035
function Util:strsplit(input, sep)
	local t = {}
	for s in string.gmatch(input, "([^"..sep.."]+)") do
		table.insert(t, s)
	end
	return t
end

return Util
