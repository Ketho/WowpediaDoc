import os, re
import xml.etree.ElementTree as ET
import pywikibot

def find_xml():
	folder = "wowpedia/api/20220202 edit redirect"
	for name in os.listdir(folder):
		if name.find(".xml") > -1:
			tree = ET.parse(folder+"/"+name)
			root = tree.getroot()
	return root

def read_xml(root):
	xmlns = "{http://www.mediawiki.org/xml/export-0.10/}"
	l = []
	for page in root.findall(xmlns+"page"):
		name = page[0].text
		for revision in page.findall(xmlns+"revision"):
			for text in revision.findall(xmlns+"text"):
				if "redirect=no" in text.text:
					l.append(name)
	return l

def main():
	wowpedia_xml = find_xml()
	names = read_xml(wowpedia_xml)

	site = pywikibot.Site('en', 'wowpedia')
	for name in names:
		page = pywikibot.Page(site, name)
		res = re.findall("(\[.+redirect=no (.+)\(\)\])", page.text)
		if res:
			new = str.format("{{{{api|{0}}}}}()", res[0][1])
			page.text = page.text.replace(res[0][0], new)
			page.save("Clean up noredirect")

main()
print("done")
