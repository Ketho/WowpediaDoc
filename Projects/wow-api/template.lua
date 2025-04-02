local Templates = {
	["AccountBankItemButtonTemplate"] = {type = "ItemButton", inherits = "BankItemButtonTemplate"},
	["AccountLoginBackdropTemplate"] = {type = "Frame", inherits = "TooltipBackdropTemplate"},
	["AccountNameButtonTemplate"] = {type = "Button", mixin = "AccountNameMixin"},
}

local words = {"Template", "ScrollBox", "ScrollBar"}

local function isValidName(s)
	for _, word in ipairs(words) do
		if s:find(word) then
			return true
		end
	end
end

for k in pairs(Templates) do
	if isValidName(k) then
		print(k)
	end
end
