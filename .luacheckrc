std = "lua53"
max_line_length = false
exclude_files = {
	".install",
	".luarocks",
	"Blizzard_APIDocumentation",
}
ignore = {
	"212/self", -- unused argument self
}
globals = {
	"ChatTypeInfo",
	"DEFAULT_CHAT_FRAME",
	"unpack",
	"Mixin",
	"CreateFromMixins",
	"Wowpedia",
	"string.split",
	"APIDocumentation",
}
