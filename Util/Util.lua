local lfs = require "lfs"
local Path = require "path"
local https = require "ssl.https"
local ltn12 = require "ltn12"
local parser = require "Util/wago_csv"

local Util = {}
local INVALIDATION_TIME = 60*60

-- useful when using PTR builds and a retail build is higher than a PTR build
-- e.g. PTR 10.1.7.50587 vs retail 10.1.5.50622
function Util.SortPatch(a, b)
	local major_a, minor_a, patch_a, build_a = a:match("(%d+)%.(%d+)%.(%d+)%.(%d+)")
	local major_b, minor_b, patch_b, build_b = b:match("(%d+)%.(%d+)%.(%d+)%.(%d+)")
	major_a = tonumber(major_a); major_b = tonumber(major_b)
	minor_a = tonumber(minor_a); minor_b = tonumber(minor_b)
	patch_a = tonumber(patch_a); patch_b = tonumber(patch_b)
	build_a = tonumber(build_a); build_b = tonumber(build_b)
	if major_a ~= major_b then
		return major_a < major_b
	elseif minor_a ~= minor_b then
		return minor_a < minor_b
	elseif patch_a ~= patch_b then
		return patch_a < patch_b
	elseif build_a ~= build_b then
		return build_a < build_b
	end
end

function Util.SortBuild(a, b)
	local build_a = tonumber(a:match("(%d+)$"))
	local build_b = tonumber(b:match("(%d+)$"))
	if build_a ~= build_b then
		return build_a < build_b
	end
end

Util.PtrVersion = "10.2.7"

local flavorInfo = {
	mainline_beta = {flavor = "mainline", branch = "wow_beta", header = true},
	mainline_ptr = {flavor = "mainline", branch = "wowt", header = true},
	mainline = {flavor = "mainline", branch = "wow", header = true},
	vanilla = {flavor = "vanilla", header = true, branch = "wow_classic_era"},
	-- vanilla_ptr has 10.1.5 and 10.0.7 builds
	vanilla_ptr = {flavor = "vanilla", branch = "wow_classic_era_ptr", header = true},
	wrath = {flavor = "wrath", header = true, branch = "wow_classic"},
	wrath_ptr = {flavor = "wrath", header = true, branch = "wow_classic_ptr"},
	cata_ptr = {flavor = "cata", header = true, branch = "wow_classic_beta"},
}

local classicVersions = {
	"^1.13.",
	"^1.14.",
	"^1.15.",
	"^2.5.",
	"^3.4.",
}

Util.RelativePath = {
	["."] = true,
	[".."] = true,
}

function Util:GetLatestBuild(flavor)
	local folder = Path.join("FrameXML", flavor)
	if not lfs.attributes(folder) then
		error("path does not exist: "..folder)
	end
	local t = {}
	for name in lfs.dir(folder) do
		local build = name:match("%((%d+)%)")
		if build then
			table.insert(t, {name = name, build = build})
		end
	end
	table.sort(t, function(a, b)
		return tonumber(a.build) > tonumber(b.build)
	end)
	local path = Path.join(folder, t[1].name)
	print("# Util:GetLatestBuild", path)
	return path
end

function Util:LoadDocumentation(branch)
	require("WowDocLoader.WowDocLoader"):main(branch)
end

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
	local p = path:gsub("%.lua", "")
	if p:find("%.") then
		return loadfile(path)()
	else
		return require(p)
	end
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
		end
	end
end

function Util:ShouldDownload(path, isCache)
	local attr = lfs.attributes(path)
	if not attr then
		return true
	elseif isCache and os.time() > attr.modification + (type(isCache) == "number" and isCache or INVALIDATION_TIME) then
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

function Util:ToList(tbl, func)
	local t = {}
	for _, v in pairs(tbl) do
		table.insert(t, v)
	end
	table.sort(t, func)
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
	local system = apiTable.System
	if system.Type == "System" then
		if system.Namespace then
			fullName = format("%s.%s", system.Namespace, apiTable.Name)
		else
			fullName = apiTable.Name
		end
	elseif system.Type == "ScriptObject" then
		fullName = format("%s:%s", system.Name, apiTable.Name)
	end
	return fullName
end

function Util:GetPatchVersion(v)
	return v:match("%d+%.%d+%.%d+")
end

function Util:GetPatchText(patchData, ID, patch_override)
	local version = self:GetPatchVersion(patchData[ID].patch)
	local text = patch_override and patch_override[version] or version
	if text == self.PtrVersion then
		text = text.." [[File:PTR_client.png|16px|link=]]"
	end
	return text
end

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
		local t = flavorInfo[info]
		if t.branch then
			t.build = parser:GetWagoVersions(t.branch)[1] -- latest build for a branch
		end
		t.sort = Util.SortPatch
		return t
	elseif not info then
		return flavorInfo.mainline
	end
end

function Util:ReadCSV(dbc, parser, options, func)
	-- print("DBC", dbc)
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

-- https://stackoverflow.com/a/32660766/1297035
function Util:equals(a, b)
    if a == b then return true end
    local type_a, type_b = type(a), type(b)
    if type_a ~= type_b then return false end
    if type_a ~= "table" then return false end
    for k, v in pairs(a) do
        if b[k] == nil or not self:equals(v, b[k]) then return false end
    end
    for k in pairs(b) do
        if a[k] == nil then return false end
    end
    return true
end

function Util:Print(...)
	if self.DEBUG then
		print(...)
	end
end

function Util:LoadLuaEnums(branch)
	local path = string.format("cache_lua/LuaEnum_%s.lua", branch)
	local url = string.format("https://raw.githubusercontent.com/Ketho/BlizzardInterfaceResources/%s/Resources/LuaEnum.lua", branch)
	Util:DownloadAndRun(path, url)
	-- Meta fields are not written to LuaEnum.lua
	Enum.LFGRoleMeta = {NumValue = 3} -- 10.2.5 LFGConstantsDocumentation.lua
end

return Util
