-- https://wowpedia.fandom.com/wiki/MovieID
local Util = require("Util/Util")
local parser = require("Util/wowtoolsparser")
local wowpedia_export = require("Util/wowpedia_export")
local dbc_patch = require("Projects/DBC/DBC_patch")

local OUTPUT = "out/page/MovieID.txt"

local function GetDescriptions()
	local page = wowpedia_export:get_api_page("MovieID")
	local t = {}
	for line in page:gmatch("(.-)\n") do
		if line:find("||") then
			-- maybe need a strsplit function that supports this
			local id, yt, desc = line:match("| (.*) || .* || (.*) || (.*) || .*")
			if desc then
				t[tonumber(id)] = {desc, yt}
			end
		end
	end
	return t
end

local function main(options)
	options = Util:GetFlavorOptions(options)
	-- a ptr build was lower (9.2.5.43254) than the latest live build (9.2.0.43340)
	-- options.sort = nil

	local filedata = parser:ReadListfile()
	local patchData = dbc_patch:GetPatchData("movie", options)
	print("writing to "..OUTPUT)
	local file = io.open(OUTPUT, "w")

	-- there are multiple avi files with different resolutions per movieid
	-- but we only care about the fallback filename if there is no sound
	local movievariation = {}
	Util:ReadCSV("movievariation", parser, options, function(_, _, l)
		local fdid = tonumber(l.FileDataID)
		local fd = filedata[fdid]
		local name = ""
		if fd then
			name = fd:match("interface/cinematics/(.+)_%d+%.avi")
			if not name then -- hack
				name = filedata[fdid]:match("interface/cinematics/(.+)%.avi")
			end
		end
		local movieid = tonumber(l.MovieID)
		movievariation[movieid] = name
	end)

	local descriptions = GetDescriptions()
	local duplicates = {}
	file:write('{| class="sortable darktable zebra col1-center col3-center"\n! ID !! Name !! YouTube !! Description !! Patch\n')
	local fs = '|-\n| %d || %s || %s || %s || %s\n'
	Util:ReadCSV("movie", parser, options, function(_, ID, l)
		local audio = tonumber(l.AudioFileDataID)
		local name = ""
		if audio == 0 then
			name = movievariation[ID]
		else
			local fd = filedata[audio]
			if fd then
				name = fd:match("interface/cinematics/(.+)%.mp3")
			end
		end
		local desc, yt = "", ""
		if descriptions[ID] then
			desc, yt = table.unpack(descriptions[ID])
		end
		if duplicates[name] then
			name = string.format('<font color="gray">%s</font>', name)
			desc = '<font color="gray">~</font>'
		else
			if #name > 0 then -- can be empty
				duplicates[name] = true
			end
		end

		local patch = patchData[ID] and Util:GetPatchVersion(patchData[ID]) or ""
		patch = Util.patchfix[patch] or patch
		if patch == Util.PtrVersion then
			patch = patch.." {{Test-inline}}"
		end
		file:write(fs:format(ID, name, yt, desc, patch))
	end)
	file:write("|}\n")
	file:close()
end

main()
print("done")
