local Path = require "path"

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
    local pywikibot_path = "F:\\Repo\\wow-dev\\pywikibot"
    os.execute(string.format("py %s\\pwb.py login", pywikibot_path))
    os.execute(string.format("py %s\\pwb.py Scribunto\\upload.py", pywikibot_path))
end

local function main()
    WriteFiles()
    UploadFiles()
end

main()
