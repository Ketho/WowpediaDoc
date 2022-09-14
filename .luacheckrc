std = "lua53"
max_line_length = false
exclude_files = {
	"Util/csv/csv.lua",
	"Pages/API_DoEmote.lua",
}
ignore = {
	"211", -- unused local variable / function
	"212/ID", -- unused argument
	"212/self",
}
globals = {
	"ApiDocsDiff",
	"APIDocumentation",
	"BATTLE_PET_SOURCE_1",
	"BATTLE_PET_SOURCE_2",
	"BATTLE_PET_SOURCE_3",
	"BATTLE_PET_SOURCE_4",
	"BATTLE_PET_SOURCE_5",
	"BATTLE_PET_SOURCE_6",
	"BATTLE_PET_SOURCE_7",
	"BATTLE_PET_SOURCE_8",
	"BATTLE_PET_SOURCE_9",
	"BATTLE_PET_SOURCE_10",
	"BATTLE_PET_SOURCE_11",
	"bit",
	"C_Console",
	"C_Map",
	"C_MountJournal",
	"C_PetJournal",
	"C_ToyBox",
	"ChatTypeInfo",
	"CreateFrame",
	"CreateFromMixins",
	"DEFAULT_CHAT_FRAME",
	"Enum",
	"ExportSystems",
	"format",
	"GetCVarInfo",
	"GetGameMessageInfo",
	"GetNumExpansions",
	"KethoEditBox",
	"KethoWowpedia",
	"Mixin",
	"mw",
	"sort",
	"string.split",
	"strmatch",
	"tinsert",
	"UIParent",
	"unpack",
	"Wowpedia",
	"ChangeDiff",
}
