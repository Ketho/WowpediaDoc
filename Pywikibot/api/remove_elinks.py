import re
import json
import pywikibot

site = pywikibot.Site('en', 'wowpedia')

with open('wowpedia/data/globalapi.json', 'r') as f:
    data = f.read()
globalapi = json.loads(data)

def findElinkSection():
	for name in globalapi:
		page = pywikibot.Page(site, "API "+name)
		lower = page.text.lower()
		idx = lower.find("external links")
		if idx > -1:
			print("#", name)
			print(page.text[idx:])

def removeOldElinkStyle():
	for name in globalapi:
		page = pywikibot.Page(site, "API "+name)
		wp_elinks = re.findall(r"==\s?External links\s?==\n<!-- Please read.*\n{{Elinks-api.*", page.text)
		if wp_elinks:
			page.text = page.text.replace(wp_elinks[0], "")
			page.save(summary="Remove elinks")

def findWhitespace():
	for name in globalapi:
		page = pywikibot.Page(site, "API "+name)
		whitespace_refs = re.findall(r"\n\n\n==\s?References\s?==", page.text)
		if whitespace_refs:
			print(name)

# findElinkSection()
# removeOldElinkStyle()
# findWhitespace()
print("done")
