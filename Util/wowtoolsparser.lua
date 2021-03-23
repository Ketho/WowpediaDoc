local lfs = require "lfs"
local cURL = require "cURL"
local cjson = require "cjson"
local cjsonutil = require "cjson.util"
local csv = require "csv"
local parser = {}

local user_agent = "your user agent here"

local listfile_url = "https://wow.tools/casc/listfile/download/csv/unverified"
--local databases_url = "https://api.wow.tools/databases"
local versions_url = "https://api.wow.tools/databases/%s/versions"
local csv_url = "https://wow.tools/api/export/?name=%s&build=%s"
local json_url = "https://wow.tools/api/data/%s/?build=%s&length=%d" -- saves them a slice call

if not lfs.attributes("out/cache") then
	lfs.mkdir("out/cache")
end
local listfile_cache = "out/cache/listfile.csv"
local versions_cache = "out/cache/%s_versions.json"
local csv_cache = "out/cache/%s_%s.csv"
local json_cache = "out/cache/%s_%s.json"

--- Sends an HTTP GET request.
-- @param url the URL of the request
-- @param file (optional) file to be written
-- @return string if file is given, the HTTP response
local function HTTP_GET(url, file)
	local data, idx = {}, 0
	cURL.easy{
		url = url,
		writefunction = file or function(str)
			idx = idx + 1
			data[idx] = str
		end,
		ssl_verifypeer = false,
		useragent = user_agent,
	}:perform():close()
	return table.concat(data)
end

--- Gets all build versions for a database.
-- @param name the DBC name
-- @return table available build versions
local function GetVersions(name)
	local path = versions_cache:format(name)
	local file = io.open(path, "w")
	HTTP_GET(versions_url:format(name), file)
	file:close()
	local json = cjsonutil.file_load(path)
	local tbl = cjson.decode(json)
	return tbl
end

--- Finds a wow.tools build.
-- @param name the DBC name
-- @param build the build to search for
-- @return string the build number (e.g. "8.2.0.30993")
local function FindBuild(name, build)
	local versions = GetVersions(name)
	if build then
		for _, version in pairs(versions) do
			if version:find(build) then
				return version
			end
		end
		error(string.format("build \"%s\" is not available for %s", build, name))
	else
		return versions[1] -- the most recent build
	end
end

--- Parses the DBC (with header) from CSV.
-- @param name the DBC name
-- @param options.build (optional) the build version, otherwise falls back to the most recent build
-- @param options.header (optional) if true, each set of fields will be keyed by header name, otherwise by column index
-- @return function the csv iterator
function parser.ReadCSV(name, options)
	options = options or {}
	local build = FindBuild(name, options.build)
	-- cache csv
	local path = csv_cache:format(name, build)
	if not lfs.attributes(path) then
		local file = io.open(path, "w")
		HTTP_GET(csv_url:format(name, build), file)
		file:close()
	end
	print(string.format("reading %s.csv build %s", name, build))
	local iter = csv.open(path, options.header and {header = true})
	return iter
end

--- Parses the DBC from JSON.
-- @param name the DBC name
-- @param options.build (optional) the build version, otherwise falls back to the most recent build
-- @return table the converted json table
function parser.ReadJSON(name, options)
	options = options or {}
	local build = FindBuild(name, options.build)
	-- cache json
	local path = json_cache:format(name, build)
	if not lfs.attributes(path) then
		local file = io.open(path, "w")
		-- get number of records
		local initialRequest = HTTP_GET(json_url:format(name, build, 0))
		local recordsTotal = cjson.decode(initialRequest).recordsTotal
		-- write json to file
		HTTP_GET(json_url:format(name, build, recordsTotal), file)
		file:close()
	end
	print(string.format("reading %s.json build %s", name, build))
	local json = cjsonutil.file_load(path)
	local tbl = cjson.decode(json).data
	return tbl
end

--- Parses the CSV listfile.
-- @param refresh (optional) if the listfile should be redownloaded
function parser.ReadListfile(refresh)
	-- cache listfile
	if refresh or not lfs.attributes(listfile_cache) then
		print("downloading listfile...")
		local file = io.open(listfile_cache, "w")
		HTTP_GET(listfile_url, file)
		file:close()
	end
	-- read listfile
	local iter = csv.open(listfile_cache, {separator = ";"})
	local filedata = {}
	print("reading listfile...")
	for line in iter:lines() do
		local fdid, filePath = tonumber(line[1]), line[2]
		filedata[fdid] = filePath
	end
	print("finished reading.")
	return filedata
end

function parser.ExplodeCSV(iter)
	for line in iter:lines() do
		print(table.unpack(line))
	end
end

function parser.ExplodeJSON(tbl)
	for _, line in pairs(tbl) do
		print(table.unpack(line))
	end
end

function parser.ExplodeListfile(tbl)
	for fdid, path in pairs(tbl) do
		print(fdid, path)
	end
end

return parser
