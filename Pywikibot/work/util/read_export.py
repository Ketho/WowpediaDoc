import os
import xml.etree.ElementTree as ET

# def find_xml():
# 	folder = "Pywikibot/export/parse_html"
# 	for name in os.listdir(folder):
# 		if name.find(".xml") > -1:
# 			return Path(folder, name)

def read_xml(func, path):
	tree = ET.parse(path)
	root = tree.getroot()
	xmlns = "{http://www.mediawiki.org/xml/export-0.11/}"
	l = []
	for page in root.findall(xmlns+"page"):
		name = page[0].text
		name = name.replace("API ", "")
		name = name.replace(" ", "_") # spaces are undescores in page names
		for revision in page.findall(xmlns+"revision"):
			for text in revision.findall(xmlns+"text"):
				newText = func(name, text.text)
				if newText:
					l.append([page[0].text, newText])
	return l

def main(func, path):
	return read_xml(func, path)
