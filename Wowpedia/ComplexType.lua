function GetComplexType(obj)
	if obj.Mixin then
		return string.format("[[%s]]", obj.Mixin)
	end
end
