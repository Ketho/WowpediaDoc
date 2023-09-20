local flavor_module = require("Module:API_info/flavor")
local elink_module = require("Module:API_info/elink")
local patch_module = require("Module:API_info/patch")
-- local metrics_module = require("Module:API_info/metrics")
local group_data_module = require("Module:API_info/util/group_data")
local m = {}

local INFOBOX_STYLE = '<div class="nomobile>\n%s\n</div>'

-- cannot use # operator on mw.loadData tables
local function GetTableSize(tbl)
	local size = 0
	for _ in pairs(tbl) do
		size = size + 1
	end
	return size
end

local function FormatCodeOrLink(name, apiName)
	local firstChar = name:sub(1, 1)
	local text
	if firstChar == "#" then
		name = name:sub(2)
		text = name
	-- bit ugly to implement @ prefix
	elseif firstChar == "@" then
		name = name:sub(2)
		local fs = name ~= apiName and "[https://wowpedia.fandom.com/wiki/API_%s?redirect=no %s]" or "[[API %s|%s]]"
		text = fs:format(name, name)
	else
		text = string.format("[[API %s|%s]]", name, name)
	end
	return string.format("<code>%s</code>", text)
end

local function FormatIcon(item)
	item.iconsize = item.iconsize or 16
	local fs = "[[File:%s|%dpx|link=%s]]"
	return fs:format(item.icon, item.iconsize, item.url)
end

function m:GetFlavorIcons(args, name)
	local data = flavor_module:GetFlavors(args.t, name)
	if data then
		local t = {}
		for _, item in pairs(data) do
			table.insert(t, FormatIcon(item))
		end
		return table.concat(t)
	end
end

function m:GetElinkIcons(args, name)
	local data = elink_module:GetElinks(args.t, name)
	if data then
		local t = {}
		for _, item in pairs(data) do
			table.insert(t, FormatIcon(item))
		end
		return table.concat(t, " &nbsp;")
	end
end

function m:GetMetrics(args, name)
	local data = elink_module:GetElinks(args.t, name)
	if data then
		local t = {}
		for _, item in pairs(data) do
			table.insert(t, FormatIcon(item))
		end
		return table.concat(t, " &nbsp;")
	end
end

function m:CreateInfobox(args, apiName)
	local group = group_data_module.data[apiName]
	local t = {}
	table.insert(t, '{| class="darktable" cellpadding=4')
	for _, name in pairs(group) do
		local prefixName = name
		name = group_data_module:GetNonPrefixName(name)
		table.insert(t, "\n|-\n| ")
		table.insert(t, string.format("%s || ", self:GetElinkIcons(args, name) or ""))
		local api_text = FormatCodeOrLink(prefixName, apiName)
		local t_size = GetTableSize(group)
		if t_size > 2 and name == apiName then
			api_text = string.format('<font color="#dda0dd">%s</font>', api_text)
		end
		table.insert(t, string.format("%s || ", api_text))
		table.insert(t, string.format("%s || ", self:GetFlavorIcons(args, name) or ""))
		local added, removed = patch_module:GetPatches(args.t, name)
		if #added > 0 then
			table.insert(t, "|| <font color=#00b400>+</font> "..added)
		end
		if #removed > 0 then
			table.insert(t, ", <font color=#ff6767>-</font> "..removed)
		end
		-- local metrics = metrics_module:main(args.t, name)
		-- if metrics then
		-- 	table.insert(t, " || "..metrics_module:GetScoreString(metrics))
		-- end
	end
	table.insert(t, "\n|}")
	return table.concat(t)
end

function m:GetData(name)
	return group_data_module.data[name]
end

function m:main(args, name)
	local infobox = self:CreateInfobox(args, name)
	return INFOBOX_STYLE:format(infobox)
end

return m
