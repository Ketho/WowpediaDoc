local Util = require("Util/Util")
local WikiText = require("Pages/World of Warcraft API/WikiText")
local Signatures_Parse = require("Pages/World of Warcraft API/Signatures_Parse")
local signatures = Signatures_Parse:GetSignatures()

package.path = package.path..";../?.lua"
local updated_desc = require("wow-api-descriptions/updated")

local OUTPUT = "cache_lua/World_of_Warcraft_API.txt"
local m = {}

local function MatchLine(s)
	local t = {}
	t.tags = s:match("{{apitag|(.-)}}")
	t.name = s:match("%[%[API (.-)|")
	t.signature = signatures[t.name]
	t.args = s:match("%((.-)%)")
	t.returns = s:match("%) : (.+</span>)")
	t.desc = --[[updated_desc[t.name] or]] s:match("[%)%}] %- (.+)") or s:match("%</span> %- (.+)")
	return t
end

function m:StringBuilder(info)
	local t = {}
	table.insert(t, ": ")
	if info.signature then
		table.insert(t, info.signature)
	else
		table.insert(t, string.format("[[API %s|%s]]", info.name, info.name))
		table.insert(t, string.format("(%s)", info.args or ""))
		if info.returns then
			table.insert(t, string.format(" : %s", info.returns or ""))
		end
	end
	if info.tags then
		table.insert(t, string.format(" {{apitag|%s}}", info.tags))
	end
	if info.desc then
		table.insert(t, " - "..info.desc)
	end
	return table.concat(t)
end

local isClassic

local blockedTags = {
	framexml = true,
	lua = true,
}

function m:UpdateSignatures()
	local wikitext = WikiText:GetWikitext().."\n"
	print("writing "..OUTPUT)
	local file = io.open(OUTPUT, "w")
	for line in string.gmatch(wikitext, "(.-)\n") do
		line = WikiText:ReplaceHtml(line)
		if line:match("^: (.-)") and not line:find("github.com") then
			local info = MatchLine(line)
			if not blockedTags[info.tags] then
				line = self:StringBuilder(info)
			end
		end
		file:write(line.."\n")
	end
	file:close()
end

local function main()
	WikiText:SaveExport()
	m:UpdateSignatures()
end

main()
print("done")
