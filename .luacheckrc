std = "lua53"
max_line_length = false
exclude_files = {
	"FrameXML/Blizzard_APIDocumentation",
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
}
