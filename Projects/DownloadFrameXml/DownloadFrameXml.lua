local pathlib = require("path")
local https = require("ssl.https")

local util = require("util")
local log = require("util.log")
local products = require("util.products")

local GAMETYPE = "classic" ---@type GameType
local branch = products.gameversion_branch[GAMETYPE]

-- download framexml zip
local URL = string.format("https://github.com/Gethe/wow-ui-source/archive/refs/heads/%s.zip", branch)
local VERSION = https.request(string.format("https://raw.githubusercontent.com/Gethe/wow-ui-source/refs/heads/%s/version.txt", branch))

local patch, build = VERSION:match("(%d+%.%d+%.%d+)%.(%d+)")
local fileBaseName = string.format("%s (%s)", patch, build)
local fileExtName = fileBaseName..".zip"

local gameTypeFolder = pathlib.join("FrameXML", GAMETYPE)
local zipFolder = pathlib.join("FrameXML", "zips")
local zipFile = pathlib.join(zipFolder, fileExtName)
local unpackFolder = pathlib.join(gameTypeFolder, fileBaseName)
util:DownloadFile(URL, zipFile)

-- unpack
local command = string.format('unzip "%s" -d "%s"', zipFile, unpackFolder)
util:run_command(command)
log:success("Done")
