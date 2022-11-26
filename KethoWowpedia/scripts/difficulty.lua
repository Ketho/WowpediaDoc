local eb = KethoEditBox

function KethoWowpedia:GetDifficultyIDs()
	eb:Show()
	--local header = '{| class="sortable darktable zebra"\n|-\n! ID !! Name !! Type !! isHeroic !! isChallengeMode !! displayHeroic !! displayMythic !! toggleDifficultyID\n'
	--local fs = "|-\n| %d |||| %s |||| %s |||| %s |||| %s |||| %s |||| %s |||| %d\n"
	local header = '{| class="sortable darktable zebra col1-center"\n! ID !! Name !! Type !! Notes'
	local fs = '|-\n| %d |||| %s |||| %s |||| %s'

	eb:InsertLine(header)

	for i = 1, 500 do -- where did that 147 come from
		if GetDifficultyInfo(i) then
			local difficultyName, instanceType, isHeroic, isChallengeMode, displayHeroic, displayMythic, toggleDifficultyID = GetDifficultyInfo(i)

			local t = {}
			if isHeroic then tinsert(t, "isHeroic") end
			if isChallengeMode then tinsert(t, "isChallengeMode") end
			if displayHeroic then tinsert(t, "displayHeroic") end
			if displayMythic then tinsert(t, "displayMythic") end
			if toggleDifficultyID then tinsert(t, "toggleDifficultyID: "..toggleDifficultyID) end

			eb:InsertLine(fs:format(i, difficultyName, instanceType,
				table.concat(t, ", ")))
		end
	end

	eb:InsertLine("|}")
end
