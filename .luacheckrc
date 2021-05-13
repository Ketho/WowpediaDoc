std = "lua53"
max_line_length = false
exclude_files = {
	"Documenter/FrameXML/Blizzard_APIDocumentation",
}
ignore = {
	"211", -- unused local variable / function
	"212/self", -- unused argument self
}
globals = {
	"APIDocumentation",
	"ChatTypeInfo",
	"CreateFromMixins",
	"DEFAULT_CHAT_FRAME",
	"Enum",
	"ExportSystems",
	"Mixin",
	"Wowpedia",
	"format",
	"string.split",
	"tinsert",
	"unpack",
	"KethoWowpedia",
	"KethoEditBox",
	"CreateFrame",
	"UIParent",
	"sort",
	"strmatch",
	"GetGameMessageInfo",
	"C_PetJournal",
	"C_MountJournal",
	"bit",
	"C_ToyBox",
	"GetNumExpansions",
	"C_Map",
}
