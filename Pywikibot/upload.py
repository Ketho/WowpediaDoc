import os
import pywikibot

site = pywikibot.Site("en", "wowpedia")
PATH = "out/export"

def getFileText(p):
	f = open(p)
	lines = f.readlines()
	return "".join(lines)

def saveFile(path, fileName):
	name = fileName.replace(".txt", "")
	# print("-- reading "+name)
	page = pywikibot.Page(site, name)
	if not page.exists():
		page.text = getFileText(path)
		page.save(summary="10.0.2 (45505)")

def recursiveFiles(path):
	for base in os.listdir(path):
		newPath = path+"/"+base
		if os.path.isdir(newPath):
			recursiveFiles(newPath)
		else:
			saveFile(newPath, base)

recursiveFiles(PATH)
print("done")
