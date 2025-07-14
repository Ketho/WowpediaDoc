local util = require("util")
local bir_url = "https://raw.githubusercontent.com/Ketho/BlizzardInterfaceResources/%s/Resources/WidgetAPI.lua"
local WIDGET_PATH = "cache_lua/WidgetAPI_%s.lua"

local m = {}
local pos_tbl = {}

local function GetWidgetFile(path, branch)
	local url = bir_url:format(branch)
	util:DownloadFile(url, path, true)
end

local function GetWidgetObjectName(path)
	local file = io.open(path, "r")
	local idx = 0
	local t = {}
	for line in file:lines() do
		idx = idx + 1
		local widget_name = line:match("^\t(%a+) = {")
		if widget_name then
			table.insert(t, {idx, widget_name})
		end
	end
	-- reverse the table, there was a bug with the very last idx
	for i = #t, 1, -1 do
		table.insert(pos_tbl, t[i])
	end
	file:close()
end

function m:GetWidgetByLine(widget_name, methodLine)
	for _, v in pairs(pos_tbl) do
		local sectionLine, name = table.unpack(v)
		if methodLine > sectionLine then
			return name
		end
	end
end

-- get the widget object name for a method name from the .diff and source file
function m:ParseWidgetSection(info, path)
	local file = io.open(path, "r")
	local isSection
	local section_line, offset
	for line in file:lines() do
		if isSection then
			if line:find("^@@") then
				section_line = line:match("^@@ %-%d+,%d+ %+(%d+),%d+")
				offset = -1
			elseif line:find('\t\t\t"%w+",') then
				-- only increment idx on context and added lines
				if not line:find("^%-") then
					offset = offset + 1
				end
				local sign, innerLine = line:match("^([%+%-])(.+)")
				if sign then
					local name = info.parseName(innerLine)
					local text = info.textfunc(name, section_line+offset)
					-- print(section_line+offset, text, line)
					table.insert(info.changes[sign], text)
				end
			end
		end
		if line == "+++ b/Resources/WidgetAPI.lua" then
			isSection = true
		elseif line == "diff --git a/Resources/WidgetHierarchy.png b/Resources/WidgetHierarchy.png" then
			isSection = false
		end
	end
	file:close()
end

function m.main(data_table_widget, diff_path, branch)
	local path = string.format(WIDGET_PATH, branch)
	GetWidgetFile(path, branch)
	GetWidgetObjectName(path)
	m:ParseWidgetSection(data_table_widget, diff_path)
end

return m
