-- https://wowpedia.fandom.com/wiki/Template:Apitype
local data = mw.loadData("Module:Apitype/data")
local m = {}

local suffices = {
	["%?"] = "nilable",
	["%[%]"] = "array",
}

-- cannot use table.concat
local function tconcat(t, del)
	local size = 0
	for _ in pairs(t) do
		size = size + 1
	end
	local s = ""
	for k, v in pairs(t) do
		s = s..v
		if k ~= size then
			s = s..del
		end
	end
	return s
end

-- todo: refactor
local function FormatString(args, text)
	-- need to match the dot in e.g. "Enum.AuctionHouseFilter"
	local name, symbols = text:match("([%w%._]+)([%[%]%?]*)")
	local s
	if name:find("Mixin") or data.enum[name] or #args.link > 0 then -- specifically want a colored hyperlink
		s = string.format('[[%s|<font color="#ecbc2a">%s</font>]]%s<small>🔗</small>', name, name, symbols)
	elseif name:find("Callback$") then
		s = string.format('<font color="#ecbc2a">function</font>%s : <font color="#ecbc2a"><small>%s</small></font>', symbols, name)
	elseif data.blizzardTypes[name] then
		if data.blizzardTypes[name].Type == "Mixin" then
			s = string.format('[[%s|<font color="#ecbc2a">%s</font>]]%s<small>🔗</small>', data.blizzardTypes[name].Mixin, data.blizzardTypes[name].Name, symbols)
		elseif data.blizzardTypes[name].Link then
			if data.blizzardTypes[name].Link:find("dbc:") then
				local link = string.format("https://wago.tools/db2/%s", data.blizzardTypes[name].Link:match("dbc:(.+)"))
				s = string.format('<font color="#ecbc2a">%s</font>%s <small>: <font color="#ecbc2a">[%s %s]</font></small>', data.blizzardTypes[name].Type, symbols, link, name)
			else
				s = string.format('<font color="#ecbc2a">%s</font>%s <small>: <font color="#ecbc2a">[[%s|%s]]</font></small>', data.blizzardTypes[name].Type, symbols, data.blizzardTypes[name].Link, name)
			end
		elseif data.blizzardTypes[name].Replace then
			s = string.format('[[UIOBJECT_%s|<font color="#ecbc2a">%s</font>]]%s<small>🔗</small>', data.blizzardTypes[name].Type, data.blizzardTypes[name].Type, symbols)
		elseif data.blizzardTypes[name].Values then
			s = string.format('<font color="#ecbc2a">%s</font>%s <small>: <span class="tttemplatelink"><font color="#ecbc2a">%s</font></span><span style="display:none"><small>%s</small></span></small>', data.blizzardTypes[name].Type, symbols, name, tconcat(data.blizzardTypes[name].Values, ", "))
		else
			s = string.format('<font color="#ecbc2a">%s</font>%s <small>: <font color="#ecbc2a">%s</font></small>', data.blizzardTypes[name].Type, symbols, name)
		end
		if data.blizzardTypes[name].Description then
			s = string.format('<font color="#ecbc2a"><span title="%s">%s</span></font>', data.blizzardTypes[name].Description, s)
		end
	elseif data.structure[name] then
		s = string.format('<font color="#ecbc2a"><span title="table">%s</span></font>%s', name, symbols)
	elseif data.widget[name] then
		s = string.format('<font color="#ecbc2a">[[UIOBJECT_%s|<font color="#ecbc2a">%s</font>]]%s<small>🔗</small></font>', name, name, symbols)
	elseif data.custom[name] then
		s = string.format('<font color="#ecbc2a"><span title="%s">%s</span></font>%s', data.custom[name], name, symbols)
	else
		s = string.format('<font color="#ecbc2a">%s</font>%s', name, symbols)
	end
	if #symbols > 0 then
		for k, v in pairs(suffices) do
			s = s:gsub(k, string.format('<span title="%s">%s</span>', v, k))
		end
	end
	return s
end

local function GetTypes(args)
	local text = args[1]
	local t = {}
	for s in text:gmatch("[^,]+") do
		table.insert(t, FormatString(args, s))
	end
	return table.concat(t, "|")
end

function m.main(f)
	local s = GetTypes(f.args)
	if #f.args.range > 0 then
		s = s..string.format(" <small><code>[%s]</code></small>", f.args.range)
	end
	if #f.args.default > 0 then
		s = s..string.format(' <span style="font-size:smaller; color:#dda0dd"; title="default"><code>= %s</code></span>', f.args.default)
	end
	return s
end

return m
