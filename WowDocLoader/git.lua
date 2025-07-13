

local util = require("util")
local log = require("util.log")

local m = {}

function m:pull(url, branch)
    local user, repo = url:match("https://github.com/([^/]+)/([^/]+)")
    -- clone if it doesn't exist
    if not util:FolderExists(repo) then
        print(util:run_command(string.format("git clone %s", url)))
    end
    print(util:run_command(string.format("git -C %s checkout %s && git pull", repo, branch)))
    -- show latest commit
    local lastCommit = util:run_command(string.format("git -C %s log -1", repo))
    local build = lastCommit:match("(%d+%.%d+%.%d+%s%(%d+%))")
    log:info(string.format("Last commit: %s", build))
    print(lastCommit)
end

return m
