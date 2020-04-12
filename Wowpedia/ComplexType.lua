function GetComplexType(obj)
	if obj.Mixin then
		return S.links[obj.Mixin] and string.format("[[%s]]", obj.Mixin) or obj.Mixin
	end
end
