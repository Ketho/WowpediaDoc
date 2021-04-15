-- repeatedly click the "SHOW MORE" button
-- moreBtn = document.querySelector("#more"); window.setInterval(function() {moreBtn.click()}, 1000)

local gumbo = require "gumbo"
local folder = "Projects/CursePoints"
local document = gumbo.parseFile(folder.."/data.html")
local transactions = document:getElementsByClassName("transactions")

local function SortTable(tbl)
	local t = {}
	for k in pairs(tbl) do
		table.insert(t, k)
	end
	table.sort(t)
	return t
end

local function WriteMonthDay()
	local file = io.open(folder.."/day.csv", "w")
	local year = {}
	for k, v in pairs(transactions) do
		if type(v) == "table" then
			local dataepoch = v.children[1].children[1].children[1].attributes[3].value
			local reward = v.children[2].children[1].children[1]
			if reward.className == "reward-item award" then
				local points = reward.children[1].children[1].children[1].innerHTML
				local text = string.format("%s,%s", os.date("%Y-%m-%d", dataepoch), points)
				table.insert(year, text)
			end
		end
	end
	table.sort(year)
	for _, v in pairs(year) do
		file:write(v.."\n")
	end
end

local function WriteMonth()
	local file = io.open(folder.."/month.csv", "w")
	local yearmonth = {}
	for k, v in pairs(transactions) do
		if type(v) == "table" then
			local dataepoch = v.children[1].children[1].children[1].attributes[3].value
			local reward = v.children[2].children[1].children[1]
			if reward.className == "reward-item award" then
				local points = reward.children[1].children[1].children[1].innerHTML
				local ym = os.date("%Y-%m", dataepoch)
				yearmonth[ym] = (yearmonth[ym] or 0) + points
			end
		end
	end
	for _, v in pairs(SortTable(yearmonth)) do
		local text = string.format("%s,%s\n", v, yearmonth[v])
		file:write(text)
	end
end

WriteMonthDay()
WriteMonth()
print("done")
