import os, re
import xml.etree.ElementTree as ET

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
		name = re.sub("API ", "", name)
		name = re.sub(" ", "_", name)
		for revision in page.findall(xmlns+"revision"):
			for text in revision.findall(xmlns+"text"):
				process_text(name, text.text)
	return l

def process_text(name: str, s: str):
	l = s.splitlines()
	for a in l[:3]:
		if re.findall("\{classic[\s_]only", a.lower()):
				print(name, a)

def main():
	wowpedia_xml = find_xml()
	read_xml(wowpedia_xml)
	print("done")

if __name__ == '__main__':
	main()
