import re
import read_export
import pywikibot

def parse_wikitext(name: str, s: str):
	l = s.splitlines()
	idx = 0
	hasChange = False
	for a in l[:3]:
		regex = "\s?\{\{[Cc]lassic[\s_]only\|.*\}\}"
		if re.findall(regex, a):
			l[idx] = re.sub(regex, "", a)
			hasChange = True
			idx += 1
	return hasChange, str.join("\n", l)

def main():
	changes = read_export.main(parse_wikitext)
	site = pywikibot.Site('en', 'wowpedia')
	for l in changes:
		name, text = l
		# print(name, text)
		page = pywikibot.Page(site, name)
		page.text = text
		page.save("Remove classiconly")
	print("done")

if __name__ == '__main__':
	main()
