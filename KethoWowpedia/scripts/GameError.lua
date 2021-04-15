function KethoWowpedia:GameError()
	local enums = {}
	for k, v in pairs(_G) do
		if k:find("^LE_GAME_ERR") then
			tinsert(enums, {k, v})
		end
	end
	sort(enums, function(a, b)
		return a[2] < b[2]
	end)

	local eb = KethoEditBox
	eb:Show()

	eb:InsertLine('{| class="sortable darktable zebra"\n! ID !! skit !! voice !! stringId !! GlobalString')
	local fs = "|-\n| <center>%d</center> |||| %s |||| %s |||| %s |||| %s"

	for _, tbl in pairs(enums) do
		local k, v = unpack(tbl)
		local stringId, soundKitID, voiceID = GetGameMessageInfo(v)
		-- no changes between matching stringPart from LuaEnums or GetGameMessageInfo()
		-- local stringPart = strmatch(k, "LE_GAME_ERR_(.+)")
		local stringPart = strmatch(stringId, "ERR_(.+)")
		-- Spew("", k, v, _G[v], _G["ERR_"..msg], stringId, soundKitID, voiceID)
		eb:InsertLine(fs:format(v, soundKitID or "", voiceID or "", stringId, _G["ERR_"..stringPart] or ""))
	end

	eb:InsertLine('|}')
end
