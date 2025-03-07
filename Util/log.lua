local m = {}

local fs = "[\27[%dm%s\27[0m] %s"

function m.success(msg)
    print(fs:format(32, "+", msg))
end

function m.info(msg)
    print(fs:format(34, "*", msg))
end

function m.warn(msg)
    print(fs:format(33, "!", msg))
end

function m.failure(msg)
    print(fs:format(31, "-", msg))
end

return m

-- m.success("This is a success message.")
-- m.info("This is an info message.")
-- m.warn("This is a warning message.")
-- m.failure("This is a failure message.")
