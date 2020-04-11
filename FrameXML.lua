-- FrameXML
ChatTypeInfo = {}
ChatTypeInfo.SYSTEM = {}

-- MessageFrame
DEFAULT_CHAT_FRAME = {}
function DEFAULT_CHAT_FRAME:AddMessage(message)
	print(message)
end

-- Lua API
unpack = table.unpack

-- https://stackoverflow.com/a/7615129/1297035
function string.split(inputstr, sep)
	if not sep then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return table.unpack(t)
end

-- SharedXML\Mixin.lua
function Mixin(object, ...)
	for i = 1, select("#", ...) do
		local mixin = select(i, ...);
		for k, v in pairs(mixin) do
			object[k] = v;
		end
	end

	return object;
end

-- where ​... are the mixins to mixin
function CreateFromMixins(...)
	return Mixin({}, ...)
end

-- dummy funcs
CopyToClipboard = function() end
ChatFrame_OpenChat = function() end
