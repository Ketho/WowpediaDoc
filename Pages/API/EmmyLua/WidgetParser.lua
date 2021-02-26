local socket = require "socket"
local https = require "ssl.https"
local request = https.request

local api = {}
local body = request("https://wow.gamepedia.com/Widget_API")
for line in body:gmatch("[^\r\n]+") do
	local title, args = line:match("title=\"API .-\">(.-)</a>%((.-)%)")
	if title then
		args = args:gsub("<span style=\"color:#ecbc2a; font%-size:90%%\">", "")
		args = args:gsub("</span>", "")
		args = args:gsub("%s?%[", "")
		args = args:gsub("%]", "")
		args = args:gsub(",?%s?%.%.%.", "")
		args = args:gsub(" or ", "_or_") -- temp lazy fix
		table.insert(api, {title, args})
	end
end

local emmy = "---[Documentation](https://wow.gamepedia.com/API_%s_%s)\nfunction %s:%s(%s) end\n\n"
local file = io.open("out/emmylua/widget.lua", "w")

for k, v in pairs(api) do
	local fullName, args = v[1], v[2]
	local widget, funcName = fullName:match("(%w+):(%w+)")
	file:write(emmy:format(widget, funcName, widget, funcName, args))
end

file:close()
