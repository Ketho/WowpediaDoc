# https://wowpedia.fandom.com/wiki/Template:Proglan
# https://wowpedia.fandom.com/wiki/Category:WoW_Icons:_Progenitor_Language
import os
from pathlib import Path
import pywikibot

imgPath = Path("Scribunto", "Proglan", "img")
site = pywikibot.Site("en", "wowpedia")
pageText = "[[Category:WoW Icons: Progenitor Language]]"

def uploadFile(path):
	page = pywikibot.Page(site, "File:"+path.name)
	if not page.exists():
		print("uploading", path.name)
		site.upload(
			filepage = page,
			source_filename = path,
			text = pageText,
			comment = "progenitorlang symbols",
		)

def main():
	for folder in os.listdir(imgPath):
		subPath = Path(imgPath, folder)
		if subPath.is_dir():
			for file in os.listdir(subPath):
				uploadFile(Path(subPath, file))
	print("done")

if __name__ == "__main__":
	main()
