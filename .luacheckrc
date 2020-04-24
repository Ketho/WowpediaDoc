std = "lua53"
max_line_length = false
exclude_files = {
	".install",
	".luarocks",
	"Blizzard_APIDocumentation",
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
	"format",
	"Mixin",
	"string.split",
	"tinsert",
	"unpack",
	"Wowpedia",
}
