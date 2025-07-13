

local lfs = require("lfs")
local log = require("util.log")
local m = {}

local function folder_exists(path)
    return lfs.attributes(path, "mode") == "directory"
end

local function run_command(cmd)
    local handle = io.popen(cmd)
    if handle then
        local result = handle:read("a")
        handle:close()
        return result
    end
end

function m:pull(url, branch)
    log:info(string.format("Pulling %s:%s", url, branch))
    local _, repo = url:match("https://github.com/([^/]+)/([^/]+)")
    if not folder_exists(repo) then
        log:info(string.format("Cloning %s", url))
        print(run_command(string.format("git clone %s", url)))
    end
    print(run_command(string.format("git -C %s checkout %s && git pull", repo, branch)))
    local lastCommit = run_command(string.format("git -C %s log -1", repo))
    local build = lastCommit:match("(%d+%.%d+%.%d+%s%(%d+%))")
    log:info(string.format("Last commit: %s", build))
    print(lastCommit)
end

return m
