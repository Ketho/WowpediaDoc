import util.read_export
import pywikibot
from pathlib import Path

categories = [
	"API+functions",
	"API+events",
	"Structs",
	"Enumerations",
]

rep = {
	'<span class="apitype">': "{{apitype|",
	'<span title="nilable">': "",
	'<span title="optional">': "",
	'</span>[]': "[]}}",
	'</span>?': "?",
	'</span>': "}}",
}

def replace_apitype_span(text):
	for s in rep:
		text = text.replace(s, rep[s])
	return text

def parse_wikitext(name: str, s: str):
	l = s.splitlines()
	hasChange = False
	for i, k in enumerate(l):
		if ' : <span class="apitype">' in k or ' || <span class="apitype">' in k:
			l[i] = replace_apitype_span(l[i])
			hasChange = True
	return hasChange, str.join("\n", l)

def main():
	site = pywikibot.Site("en", "wowpedia")
	folder = Path("Pywikibot", "export", "parse_html")
	for cat in categories:
		changes = util.read_export.main(parse_wikitext, Path(folder, cat+".xml"))
		for l in changes:
			name, info = l
			hasChange, text = info
			if hasChange:
				# print("\n-----", name, "\n", text)
				page = pywikibot.Page(site, name)
				page.text = text
				page.save("apitype template")
	print("done")

if __name__ == "__main__":
	main()
