local Path = require("path")
local util = require("util")
local enum = require("util.enum")
local products = require("util.products")

local PRODUCT = "wowxptr" ---@type TactProduct
local _, blizzres_branch = products:GetBranch(PRODUCT)

util:MakeDir("out")

local function WriteFiles()
    local scribunto = Path.join("Scribunto", "API_info")
    local files = {
        Path.join(scribunto, "flavor", "flavor"),
        Path.join(scribunto, "elink", "api"),
        Path.join(scribunto, "elink", "event"),
        Path.join(scribunto, "patch", "api", "api"),
        Path.join(scribunto, "patch", "event", "event"),
    }
    for _, v in pairs(files) do
        require(v)
    end
end

local function UploadFiles()
    os.execute("pwb login")
    os.execute("pwb Scribunto/upload.py")
end

local function main()
    enum:LoadLuaEnums(blizzres_branch)
    WriteFiles()
    UploadFiles()
end

main()
