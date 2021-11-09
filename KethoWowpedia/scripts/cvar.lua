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
		local fs = "|-\n| %s\n| %s\n| %s |||| %s |||| %s\n| %s"
		local githubLink = "[[File:GitHub_Octocat.png|16px|link=https://github.com/Gethe/wow-ui-source/search?q=%s]]"
		for _, v in pairs(cvars) do
			local value, defaultValue, server, character = GetCVarInfo(v.command)

			local nameText = format("[[CVar %s||%s]]", v.command, v.command)
			if not value then
				nameText = format("''%s''", nameText)
			end
			if cvar_ptr[v.command] then
				nameText = "{{Test-inline}} "..nameText
			end

			eb:InsertLine(fs:format(
				githubLink:format(v.command),
				nameText,
				defaultValue or "",
				cvar_enum[v.category],
				server and "Account" or character and "Character" or "",
				v.help and #v.help>0 and v.help or self.cvar_cache[v.command] or ""
			))
		end
	elseif commandType == Enum.ConsoleCommandType.Command then
		local fs = "|-\n| %s\n| %s\n| %s"
		for _, v in pairs(cvars) do
			local nameText = format("[[CVar %s||%s]]", v.command, v.command)
			if cvar_ptr[v.command] then
				nameText = "{{Test-inline}} "..nameText
			end
			eb:InsertLine(fs:format(
				nameText,
				cvar_enum[v.category],
				v.help and #v.help>0 and v.help or ""
			))
		end
	end
end
