import re
import read_export
import pywikibot

def parse_wikitext(name: str, s: str):
	l = s.splitlines()
	idx = 0
	hasChange = False
	oldText = '" style="margin-left: 2em"'
	newText = '" style="margin-left: 3.9em"'
	for a in l:
		if oldText in a:
			l[idx] = re.sub(oldText, newText, a)
			hasChange = True
		idx += 1
	return hasChange, str.join("\n", l)

def main():
	changes = read_export.main(parse_wikitext)
	site = pywikibot.Site("en", "wowpedia")
	for l in changes:
		name, info = l
		hasChange, text = info
		if hasChange:
			page = pywikibot.Page(site, name)
			page.text = text
			page.save("Update left margin to 3.9")
	print("done")

if __name__ == "__main__":
	main()
