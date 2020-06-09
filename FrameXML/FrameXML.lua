local m = {}

-- FrameXML
ChatTypeInfo = {}
ChatTypeInfo.SYSTEM = {}

-- MessageFrame
DEFAULT_CHAT_FRAME = {}
function DEFAULT_CHAT_FRAME:AddMessage(msg)
	print(msg)
end

-- Lua API
unpack = table.unpack

tinsert = table.insert
format = string.format

-- why is WoW so backwards
function string.split(delim, input)
	delim = delim or "%s"
	local t = {}
	for str in string.gmatch(input, "[^"..delim.."]+") do
		table.insert(t, str)
	end
	return unpack(t)
end

-- SharedXML\Mixin.lua
function Mixin(object, ...)
	for i = 1, select("#", ...) do
		local mixin = select(i, ...)
		for k, v in pairs(mixin) do
			object[k] = v
		end
	end

	return object
end

-- where ​... are the mixins to mixin
function CreateFromMixins(...)
	return Mixin({}, ...)
end

function m:LoadApiDocs()
	local toc = io.open("FrameXML/Blizzard_APIDocumentation/Blizzard_APIDocumentation.toc")
	for line in toc:lines() do
		if line:find("%.lua") then
			local file = assert(loadfile("FrameXML/Blizzard_APIDocumentation/"..line))
			file()
		end
	end
	toc:close()
	require "MissingDocumentation"
end

return m
