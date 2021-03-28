#pylint: disable = import-error
import os
import re
import pywikibot

site = pywikibot.Site('en', 'wowpedia')
PATH = "Wowpedia"

def findtly(newPath, base):
	page = pywikibot.Page(site, base.replace(".txt", ""))
	tly = re.findall(r"\* \[https://www\.townlong\-yak\.com/framexml/live/Blizzard_APIDocumentation.*", page.text)
	if tly: 
		print(base, tly[0])

def recursiveFiles(path):
	for base in os.listdir(path):
		newPath = path+"/"+base
		if os.path.isdir(newPath):
			recursiveFiles(newPath)
		else:
			findtly(newPath, base)

recursiveFiles("Wowpedia/system")

print("done")
