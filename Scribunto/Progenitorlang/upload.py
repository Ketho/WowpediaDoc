# https://wowpedia.fandom.com/wiki/Template:Proglang
# https://wowpedia.fandom.com/wiki/Category:WoW_Icons:_Progenitor_Language
import os
from pathlib import Path
import pywikibot

imgPath = Path("Projects", "progenitorlang", "img")
site = pywikibot.Site('en', 'wowpedia')
pageText = "[[Category:WoW Icons: Progenitor Language]]"

def uploadFile(path, name):
	page = pywikibot.Page(site, "File:"+name)
	if not page.exists():
		print("uploading", name)
		site.upload(
			filepage = page,
			source_filename = Path(path, name),
			text = pageText,
			comment = "progenitorlang symbols",
		)

def main():
	for folder in os.listdir(imgPath):
		subPath = Path(imgPath, folder)
		for file in os.listdir(subPath):
			if not "ingamelanguagesprogenitor" in file:
				uploadFile(subPath, file)
	print("done")

if __name__ == '__main__':
	main()
