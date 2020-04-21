std = "lua53"
max_line_length = false
exclude_files = {
	".install",
	".luarocks",
	"Blizzard_APIDocumentation",
}
ignore = {
	"212/self", -- unused argument self
	-- 211: unused local variable / function
	"211/DumpApiList",
	"211/TestFunction",
	"211/TestEvent",
	"211/TestTable",
	"211/TestTableSmart",
	"211/GetComplexTypeStats",
	"211/GetSignaturesWithMiddleOptionals",
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
