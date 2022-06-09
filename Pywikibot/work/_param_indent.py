import re
import read_export
import pywikibot

def parse_wikitext(name: str, s: str):
	l = s.splitlines()
	idx = 0
	hasChange = False
	for a in l:
		regex = "^;(\w+) : "
		m = re.findall(regex, a)
		if m:
			l[idx] = re.sub(regex, f":;{m[0]} : ", a)
			# print(l[idx])
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
			page.save("Indent params")
	print("done")

if __name__ == "__main__":
	main()
