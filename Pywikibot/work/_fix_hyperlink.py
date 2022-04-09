import re
import read_export
import pywikibot

hyperlinks = {
	"azessence": 1,
	"currency": 1,
	"journal": 1,
	"worldmap": 1,
	"conduit": 1,
	"transmogillusion": 1,
	"journal": 1,
	"spell": 1,
}

def parse_wikitext(name: str, s: str):
	l = s.splitlines()
	idx = 0
	hasChange = False
	for a in l:
		regex = "(\[\[UI_escape_sequences#(\w+)\|(.+?)]])"
		m = re.findall(regex, a)
		if m and hyperlinks.get(m[0][1]):
			l[idx] = re.sub(regex, f"[[Hyperlinks#{m[0][1]}|{m[0][2]}]]", a)
			print(l[idx])
			hasChange = True
		idx += 1
	return hasChange, str.join("\n", l)

def main():
	changes = read_export.main(parse_wikitext)
	site = pywikibot.Site("en", "wowpedia")
	for l in changes:
		name, text = l
		page = pywikibot.Page(site, name)
		page.text = text
		page.save("Fix hyperlinks to hyperlinks :p")
	print("done")

if __name__ == "__main__":
	main()
