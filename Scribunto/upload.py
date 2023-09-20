import pywikibot

site = pywikibot.Site("en", "wowpedia")

files = [
	["out\lua\API_info.flavor.api.lua", "Module:API_info/flavor/api"],
	["out\lua\API_info.flavor.event.lua", "Module:API_info/flavor/event"],

	["out\lua\API_info.elink.api.lua", "Module:API_info/elink/api"],
	["out\lua\API_info.elink.event.lua", "Module:API_info/elink/event"],

	["out/lua/API_info.patch.api_retail.lua", "Module:API_info/patch/api_retail"],
	["out/lua/API_info.patch.api_classic.lua", "Module:API_info/patch/api_classic"],
	["out/lua/API_info.patch.event_retail.lua", "Module:API_info/patch/event_retail"],
	["out/lua/API_info.patch.event_classic.lua", "Module:API_info/patch/event_classic"],
]

def getFileText(p):
	f = open(p)
	lines = f.readlines()
	return "".join(lines)

def saveFile(text, wikipath):
	page = pywikibot.Page(site, wikipath)
	page.text = text
	page.save(summary = "10.1.7 (51261)")

def main():
	for v in files:
		text = getFileText(v[0])
		saveFile(text, v[1])
	print("done upload")

if __name__ == "__main__":
	main()
