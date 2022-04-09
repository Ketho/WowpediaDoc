import os, re
import xml.etree.ElementTree as ET

def find_xml():
	folder = "Pywikibot/export"
	for name in os.listdir(folder):
		if name.find(".xml") > -1:
			tree = ET.parse(folder+"/"+name)
			return tree.getroot()

def read_xml(root, func):
	xmlns = "{http://www.mediawiki.org/xml/export-0.10/}"
	l = []
	for page in root.findall(xmlns+"page"):
		name = page[0].text
		name = re.sub("API ", "", name)
		name = re.sub(" ", "_", name)
		for revision in page.findall(xmlns+"revision"):
			for text in revision.findall(xmlns+"text"):
				newText = func(name, text.text)
				if newText:
					l.append([page[0].text, newText])
	return l

def main(func):
	wowpedia_xml = find_xml()
	return read_xml(wowpedia_xml, func)
