import pywikibot
import xml.etree.ElementTree as ET
from math import floor
from pathlib import Path
from time import time

xmlns = "{http://www.mediawiki.org/xml/export-0.11/}"
categories = [
	"API+functions",
	"Lua+functions",
	"Widget+methods",
	"API+events",
	"Structs",
	"Enums",
]

def main(func, category=None, summary=None):
	changes = get_updates(func, category)
	save_pages(changes, summary)

def get_updates(func, category):
	folder = Path("Pywikibot", "export", "parse_html")
	li = []
	if category:
		read_xml(li, func, Path(folder, category+".xml"))
	else:
		for cat in categories:
			read_xml(li, func, Path(folder, cat+".xml"))
	return li

def read_xml(li, func, path):
	tree = ET.parse(path)
	root = tree.getroot()
	for page in root.findall(xmlns+"page"):
		name = page[0].text.replace("API ", "")
		name = name.replace(" ", "_") # spaces are underscores in page names
		for revision in page.findall(xmlns+"revision"):
			for text in revision.findall(xmlns+"text"):
				newText = func(name, text.text)
				if newText:
					li.append([page[0].text, newText])

def save_pages(changes, summary):
	site = pywikibot.Site("en", "wowpedia")
	numEdits, elapsed = 0, time()
	for l in changes:
		name, text = l
		page = pywikibot.Page(site, name)
		page.text = text
		page.save(summary)
		numEdits = numEdits+1
	print(f"done. {numEdits} edits, {floor(time()-elapsed)} seconds")
