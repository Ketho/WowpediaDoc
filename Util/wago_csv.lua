local lfs = require "lfs"
local PATH = require "path"
local https = require "ssl.https"
local cjson = require "cjson"
local cjsonutil = require "cjson.util"
local csv = require "Util/csv/csv"

local cache_folder = "cache_csv"
local listfile_path = PATH.join(cache_folder, "listfile.csv")

local wago_csv_url = "https://wago.tools/db2/%s/csv"
local wago_builds_url = "https://wago.tools/api/builds"
local listfile_url = "https://raw.githubusercontent.com/wowdev/wow-listfile/master/community-listfile.csv"

local parser = {}

parser.INVALIDATION_TIME = 60*60

local function PathExists(path)
	return lfs.attributes(path)
end

local function CreateFolder(path)
	if not PathExists(path) then
		lfs.mkdir(path)
	end
end
CreateFolder(cache_folder)

local function DownloadFile(url, path)
	local res, code, _, status = https.request(url)
	if code == 200 then
		local file = io.open(path, "w")
		file:write(res)
		file:close()
	else
		print(string.format("failed: %s, HTTP %s", path, status))
	end
end

local function CreateCsvPath(csv_name, options)
	local file_name
	local t = {}
	if options then
		if options.build then
			table.insert(t, options.build)
		end
		if options.locale then
			table.insert(t, options.locale)
		end
	end
	if #t > 0 then
		file_name = string.format("%s_%s.csv", csv_name, table.concat(t, "_"))
	else
		file_name = string.format("%s.csv", csv_name)
	end
	CreateFolder(PATH.join(cache_folder, csv_name))
	return PATH.join(cache_folder, csv_name, file_name)
end

local function CreateWagoUrl(name, options)
	local url
	if options then
		local t = {}
		if options.build then
			table.insert(t, "build="..options.build)
		end
		if options.locale then
			table.insert(t, "locale="..options.locale)
		end
		url = string.format("%s?%s", wago_csv_url:format(name), table.concat(t, "&"))
	else
		url = wago_csv_url:format(name)
	end
	return url
end

local function IsStale(path)
	local modified = lfs.attributes(path).modification
	return os.time() > modified + parser.INVALIDATION_TIME
end

local function ReadJson(path)
	local json = cjsonutil.file_load(path)
	local data = cjson.decode(json)
	return data
end

function parser:ReadCSV(name, options)
	local path = CreateCsvPath(name, options)
	if not PathExists(path) or IsStale(path) then
		local url = CreateWagoUrl(name, options)
		DownloadFile(url, path)
	end
	print("reading "..path)
	local iter = csv.open(path, {header = options and options.header})
	return iter
end
-- parser:ReadCSV("mount", {header = true, build = "10.0.2.47657", locale = "deDE"})
-- parser:ReadCSV("battlepetspecies")

function parser:ReadListfile()
	if not PathExists(listfile_path) or IsStale(listfile_path) then
		print("downloading listfile...")
		DownloadFile(listfile_url, listfile_path)
	end
	local iter = csv.open(listfile_path, {separator = ";"})
	local filedata = {}
	print("reading listfile...")
	for line in iter:lines() do
		local fdid, filePath = tonumber(line[1]), line[2]
		filedata[fdid] = filePath
	end
	print("finished reading.")
	return filedata
end
-- parser:ReadListfile()

function parser:PrintCSV(iter)
	for line in iter:lines() do
		print(table.unpack(line))
	end
end
-- parser:PrintCSV(parser:ReadCSV("mount"))

function parser:GetVersions(branch)
	local t = {}
	local path = PATH.join(cache_folder, "versions.json")
	local versions = DownloadFile(wago_builds_url, path)
	local data = ReadJson(path)
	for _, v in pairs(data[branch]) do
		table.insert(t, v.version)
	end
	return t
end

local function GetHighestPatchBuilds()
	local t = {}
	local patches = {}
	for _, version in pairs(parser:GetVersions("wow")) do
		local major = version:match("(%d+%.%d+%.%d+)%.")
		if not patches[major] then
			patches[major] = version
			table.insert(t, version)
		end
	end
	return t
end

local function DownloadCsvHistory()
	for _, version in pairs(GetHighestPatchBuilds()) do
		parser:ReadCSV("mount", {
			header = true,
			build = version,
			locale = "enUS", -- bug: sometimes the default locale can be non-english
		})
	end
end
-- DownloadCsvHistory()

function parser:FindBuild(branch, build)
	local versions = self:GetVersions(branch)
	if build then
		for _, version in pairs(versions) do
			if version:find(build, 1, true) then
				return version
			end
		end
		error(string.format("build \"%s\" is not available", build))
	else
		return versions[1] -- the most recent build
	end
end
-- print(parser:FindBuild("wow"))

return parser
