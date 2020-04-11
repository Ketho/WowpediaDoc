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

function string.split(input)
	local t = {}
	for str in string.gmatch(input, "[^%s]+") do
		table.insert(t, str)
	end
	return unpack(t)
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
