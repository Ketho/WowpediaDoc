local pathlib = require("path")
local https = require("ssl.https")
local cjson = require("cjson")
local ltn12 = require("ltn12")

local util = require("util")
local log = require("util.log")
local products = require("util.products")
local tags = require("util.tags")

-- os.getenv("GITHUB_TOKEN") did not return the token on WSL even if the env var was set
local GITHUB_TOKEN = util:run_command("gh auth token")

local BRANCH = "ptr2" ---@type GetheBranch

local m = {}

---@type table<GetheBranch, string>
local branches = {
	live = "mainline",
	ptr = "mainline",
	ptr2 = "mainline",
	beta = "mainline",
	classic = "mists",
	classic_ptr = "mists",
	classic_beta = "mists",
	classic_era = "vanilla",
	classic_era_ptr = "vanilla",
}

--  idk why sometimes I get HTTP 400 and 403
local function SendHttpsRequest(url)
	local headers = {
		["Authorization"] = "Bearer "..GITHUB_TOKEN,
		["User-Agent"] = "WowpediaDoc/1.0"
	}
	local body = {}
	local _, code = https.request{
		url = url,
		headers = headers,
		sink = ltn12.sink.table(body)
	}
	if code ~= 200 then
		-- for some reason this block is load bearing
		error("HTTP status code "..code)
	end
	local res = table.concat(body)
	local data = cjson.decode(res)
	return data
end

function m:DownloadZip(name)
	local url, version
	local isTag = name:find("%d+%.%d+%.%d+")
	if branches[name] then
		url, version = self:GetGithubBranch(name)
	elseif isTag then
		url, version = self:GetGithubTag(name)
	else
		error("No known branch or valid tag found")
	end
	local patch, build = self:GetPatchBuild(name, version)
	local fileBaseName = string.format("%s (%s)", patch, build)
	local fileExtName = fileBaseName..".zip"

	local zipFolder = pathlib.join("FrameXML", "zips")
	local zipFile = pathlib.join(zipFolder, fileExtName)
	util:DownloadFile(url, zipFile)
end

function m:GetGithubBranch(v)
	local URL_BRANCH = "https://github.com/Gethe/wow-ui-source/archive/refs/heads/%s.zip"
	-- version.txt is included since 11.0.7
	local URL_BRANCH_VERSION = "https://raw.githubusercontent.com/Gethe/wow-ui-source/refs/heads/%s/version.txt"
	local version = https.request(URL_BRANCH_VERSION:format(v))
	return URL_BRANCH:format(v), version
end

function m:GetGithubTag(v)
	local URL_TAG = "https://github.com/Gethe/wow-ui-source/archive/refs/tags/%s.zip"
	local version = self:GetCommitVersion(v)
	return URL_TAG:format(v), version
end

function m:GetCommitVersion(tag)
	local tag_url = string.format("https://api.github.com/repos/Gethe/wow-ui-source/git/refs/tags/%s", tag)
	local data1 = SendHttpsRequest(tag_url)

	local commits_url = string.format("https://api.github.com/repos/Gethe/wow-ui-source/git/commits/%s", data1.object.sha)
	local data2 = SendHttpsRequest(commits_url)

	local version = data2.message
	return version
end

function m:GetPatchBuild(name, msg)
	-- up to 5.2.0 is in "Build %d" format
	if msg:find("Build") then -- Build 16650
		local build = msg:match("Build (%d+)")
		return name, build
	end
	local patterns = {
		"(%d+%.%d+%.%d+)%.(%d+)",    -- 11.1.7.61967
		"(%d+%.%d+%.%d+) %((%d+)%)", -- 11.1.7 (61967)
	}
	for _, v in pairs(patterns) do
		local patch, build = msg:match(v)
		if patch then
			-- print(patch, build)
			return patch, build
		end
	end
end

local function main()
	for _, v in pairs(tags.live) do
		m:DownloadZip(v)
	end
end
main()

-- unpack
-- local unpackFolder = pathlib.join(gameTypeFolder, fileBaseName)
-- local command = string.format('unzip "%s" -d "%s"', zipFile, unpackFolder)
-- util:run_command(command)

log:success("Done")
