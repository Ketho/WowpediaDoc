local lfs = require "lfs"
local https = require "ssl.https"
local ltn12 = require "ltn12"

local Util = {}
local INVALIDATION_TIME = 60*60

function Util.SortBuild(a, b)
	local build_a = tonumber(a:match("(%d+)$"))
	local build_b = tonumber(b:match("(%d+)$"))
	if build_a ~= build_b then
		return build_a < build_b
	end
end

Util.PtrVersion = "9.2.5"

local flavorInfo = {
	ptr = {flavor = "mainline", header = true,
		sort = Util.SortBuild},
	mainline = {flavor = "mainline", header = true, build = "9.2.0.",
		sort = Util.SortBuild},
	tbc = {flavor = "tbc", header = true, build = "2.5.4."},
	vanilla = {flavor = "vanilla", header = true, build = "1.14.3."},
}

Util.RelativePath = {
	["."] = true,
	[".."] = true,
}

function Util:MakeDir(path)
	if not lfs.attributes(path) then
		lfs.mkdir(path)
	end
end

function Util:WriteFile(path, text)
	print("Writing", path)
	local file = io.open(path, "w")
	file:write(text)
	file:close()
end

--- Downloads a file
---@param path string Path to write the file to
---@param url string URL to download from
---@param isCache boolean If the file should be redownloaded after `INVALIDATION_TIME`
function Util:DownloadFile(path, url, isCache)
	if self:ShouldDownload(path, isCache) then
		local body = https.request(url)
		self:WriteFile(path, body)
	end
end

--- Downloads and runs a Lua file
---@param path string Path to write the file to
---@param url string URL to download from
---@return ... @ The values returned from the Lua file, if applicable
function Util:DownloadAndRun(path, url)
	self:DownloadFile(path, url, true)
	return require(path:gsub("%.lua", ""))
end

--- Sends a POST request and downloads a file
---@param path string Path to write the file to
---@param url string URL to download from
---@param requestBody string Contents of the request
---@param isCache boolean If the file should be redownloaded after `INVALIDATION_TIME`
function Util:DownloadFilePost(path, url, requestBody, isCache)
	if self:ShouldDownload(path, isCache) then
		local body = self:HttpPostRequest(url, requestBody)
		if body then
			self:WriteFile(path, body)
			return true
		end
	end
end

function Util:ShouldDownload(path, isCache)
	local attr = lfs.attributes(path)
	if not attr then
		return true
	elseif isCache and os.time() > attr.modification+INVALIDATION_TIME then
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
	if code == 204 then -- tly no result
		return false
	elseif code ~= 200 then
		error("HTTP error: "..code)
	end
	return table.concat(response)
end

function Util:CopyTable(tbl)
	local t = {}
	for k, v in pairs(tbl) do
		t[k] = v
	end
	return t
end

function Util:Wipe(tbl)
	for k in pairs(tbl) do
		tbl[k] = nil
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

function Util.SortNocase(a, b)
	return a:lower() < b:lower()
end

-- https://stackoverflow.com/a/7615129/1297035
function Util:strsplit(input, sep)
	local t = {}
	for s in string.gmatch(input, "([^"..sep.."]+)") do
		table.insert(t, s)
	end
	return t
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

function Util:GetFullName(apiTable)
	local fullName
	if apiTable.System.Namespace then
		fullName = format("%s.%s", apiTable.System.Namespace, apiTable.Name)
	else
		fullName = apiTable.Name
	end
	return fullName
end

function Util:GetPatchVersion(v)
	return v:match("%d+%.%d+%.%d+")
end

local classicVersions = {
	"^1.13.",
	"^1.14.",
	"^2.5.",
}

function Util:IsClassicVersion(v)
	for _, pattern in pairs(classicVersions) do
		if v:find(pattern) then
			return true
		end
	end
	return false
end

-- accepts an options table or a game flavor
function Util:GetFlavorOptions(info)
	local infoType = type(info)
	if infoType == "table" then
		return info
	elseif infoType == "string" then
		return flavorInfo[info]
	elseif not info then
		return flavorInfo.ptr
	end
end

function Util:ReadCSV(dbc, parser, options, func)
	local csv = parser:ReadCSV(dbc, options)
	local tbl = {}
	for l in csv:lines() do
		local ID = tonumber(l.ID)
		if ID then
			func(tbl, ID, l) -- maybe bad code
		end
	end
	return tbl
end

function Util:IterateFiles(folder, func)
	for fileName in lfs.dir(folder) do
		local path = folder.."/"..fileName
		local attr = lfs.attributes(path)
		if attr.mode == "directory" then
			if not self.RelativePath[fileName] then
				self:IterateFiles(path, func)
			end
		else
			local ext = fileName:match("%.(%a+)")
			if ext == "lua" or ext == "xml" then
				func(path)
			end
		end
	end
end

return Util
