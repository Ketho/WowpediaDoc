std = "lua53"
max_line_length = false
exclude_files = {
	".install",
	".luarocks",
	"Blizzard_APIDocumentation",
}
ignore = {
	"212/self", -- unused argument self
	-- 212: unused function
	"212/DumpApiList",
	"212/TestFunction",
	"212/GetComplexTypeStats",
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

	"DumpApiList",
	"TestFunction",
	"DumpApiList",
}
