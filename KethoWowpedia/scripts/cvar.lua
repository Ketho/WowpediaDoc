-- https://wow.gamepedia.com/Console_variables/Complete_list
local eb = KethoEditBox

local cvar_ptr = {
	-- cvars
	agentLogLevel = true,
	debugAllocSingleBlade = true,
	debugAllocTrackStacktrace = true,
	debugLog0 = true,
	debugLog1 = true,
	debugLog2 = true,
	enableRefHistory = true,
	ErrorFileLog = true,
	useDebugAllocators = true,
	-- commands
	HeapUsage = true,
	HeapUsage2 = true,
	HeapUsage3 = true,
	logWowConnections = true,
	MemTimings = true,
	memTypeUsage = true,
	MemUsage = true,
	MemUsageDetailed = true,
}

local cvar_enum = {
	[0] = "Debug",
	[1] = "Graphics",
	[2] = "Console",
	[3] = "Combat",
	[4] = "Game",
	[5] = "", -- "Default",
	[6] = "Net",
	[7] = "Sound",
	[8] = "Gm",
	[9] = "Reveal",
	[10] = "None",
}

local function SortNocase(a, b)
	if a.isPTR ~= b.isPTR then
		return b.isPTR
	else
		return a.command:lower() < b.command:lower()
	end
end

local function GetCvarTypes(commandType)
	local t = {}
	local commands = C_Console.GetAllCommands()
	for _, v in pairs(commands) do
		if cvar_ptr[v.command] then
			v.isPTR = true
		end
		if v.commandType == commandType then
			tinsert(t, v)
		end
	end
	sort(t, SortNocase)
	return t
end

-- /run KethoWowpedia:GetCVars(Enum.ConsoleCommandType.Cvar)
-- /run KethoWowpedia:GetCVars(Enum.ConsoleCommandType.Command)
function KethoWowpedia:GetCVars(commandType)
	eb:Show()
	local cvars = GetCvarTypes(commandType)
	if commandType == Enum.ConsoleCommandType.Cvar then
		local fs = "|-\n| %s |||| %s |||| %s |||| %s\n| %s |||| %s |||| %s\n| %s"
		local githubLink = "[[File:GitHub_Octocat.png|16px|link=https://github.com/Gethe/wow-ui-source/search?q=%s]]"
		for _, v in pairs(cvars) do
			local value, defaultValue, server, character, _, secure = GetCVarInfo(v.command)

			local nameText = format("[[CVar %s||%s]]", v.command, v.command)
			if not value then
				nameText = format("''%s''", nameText)
			end
			if cvar_ptr[v.command] then
				nameText = "[[File:PTR_client.png|16px|link=]] "..nameText
			end
			defaultValue = defaultValue and #defaultValue>0 and format("<font color=#ecbc2a><code>%s</code></font>", defaultValue) or ""
			if v.command == "telemetryTargetPackage" then -- too long
				defaultValue = "..."
			end
			local cache = self.cvar_cache.var[v.command]
			if cache then
				-- the category resets back to 5 seemingly randomly
				if v.category == 5 then
					v.category = cache[2]
				end
				if v.help and #v.help == 0 then
					v.help = cache[5]
				end
			end
			eb:InsertLine(fs:format(
				self.patch.cvar[v.command] or "",
				self.cvar_framexml[v.command] and githubLink:format(v.command) or "",
				secure and "<span title=secure>🛡️</span>" or "",
				nameText,
				defaultValue,
				cvar_enum[v.category],
				server and "Account" or character and "Character" or "",
				v.help or ""
			))
		end
	elseif commandType == Enum.ConsoleCommandType.Command then
		local fs = "|-\n| %s\n| %s\n| %s"
		for _, v in pairs(cvars) do
			local nameText = format("[[CVar %s||%s]]", v.command, v.command)
			if cvar_ptr[v.command] then
				nameText = "[[File:PTR_client.png|16px|link=]] "..nameText
			end
			eb:InsertLine(fs:format(
				nameText,
				cvar_enum[v.category],
				v.help and #v.help>0 and v.help or ""
			))
		end
	end
end
