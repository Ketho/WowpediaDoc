local readFile = io.open("Pages/World of Warcraft API/Alphabetic_in.txt")
local writeFile = io.open("Pages/World of Warcraft API/Alphabetic_out.txt", "w+")

local i = 0
local lastChar
local lastWord

local blockedTags = {
    lua = true,
    framexml = true,
}

for line in readFile:lines() do
    local s = line:match(": %[%[API (.)")
    if line:sub(9, 10) == "C_" then
        local namespace = line:match("(C_%w+)")
        if lastWord ~= namespace then
            writeFile:write(string.format("==%s==\n", namespace))
        end
        writeFile:write(line.."\n")
        lastWord = namespace
    else
        local s_lower = s:lower()
        if lastChar ~= s_lower then
            writeFile:write(string.format("==%s==\n", s:upper()))
        end
        local apitag = line:match("apitag|(%w+)")
        if not blockedTags[apitag] then
            writeFile:write(line.."\n")
        end
        lastChar = s_lower
    end
end

readFile:close()
writeFile:close()
