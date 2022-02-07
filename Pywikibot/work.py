import os, re
import xml.etree.ElementTree as ET
import pywikibot

c = 0

def find_xml():
	folder = "Pywikibot/export"
	for name in os.listdir(folder):
		if name.find(".xml") > -1:
			tree = ET.parse(folder+"/"+name)
			return tree.getroot()

def read_xml(root):
	xmlns = "{http://www.mediawiki.org/xml/export-0.10/}"
	l = []
	for page in root.findall(xmlns+"page"):
		name = page[0].text
		for revision in page.findall(xmlns+"revision"):
			for text in revision.findall(xmlns+"text"):
				hasChange, newText = getChangedText(name, text.text)
				if hasChange:
					# print(hasChange, newText)
					l.append([name, newText])
	print(c)
	return l

def getChangedText(name: str, s: str):
	global c
	name = re.sub("API ", "", name)
	name = re.sub(" ", "_", name)
	l = s.splitlines()
	idx = 0
	hasChange = False
	for a in l[:7]:
		if a.startswith(" ") and "(" in a:
			if "\"" in a or ";" in a:
				c += 1
				# print(name, a, re.sub("[\";]", "", a))
				l[idx] = re.sub("[\";]", "", a)
				hasChange = True
		idx += 1
	return hasChange, str.join("\n", l)

def main():
	wowpedia_xml = find_xml()
	names = read_xml(wowpedia_xml)

	site = pywikibot.Site('en', 'wowpedia')
	for l in names:
		name, text = l
		page = pywikibot.Page(site, name)
		page.text = text
		page.save("Strip semicolons and double quotes")
	print("done")

if __name__ == '__main__':
	main()
