import os
import pywikibot

site = pywikibot.Site('en', 'wowpedia')
PATH = r"D:\Dev\Repo\wow-dev\WowpediaApiDoc\out"

def getFileText(p):
	f = open(p)
	lines = f.readlines()
	return "".join(lines)

def saveFile(path, fileName):
	name = fileName.replace(".txt", "")
	# print("-- reading "+name)
	page = pywikibot.Page(site, name)
	if not page.text:
		page.text = getFileText(path)
		page.save(summary="9.0.5")

def recursiveFiles(path):
	for base in os.listdir(path):
		newPath = path+"/"+base
		if os.path.isdir(newPath):
			recursiveFiles(newPath)
		else:
			saveFile(newPath, base)

recursiveFiles(PATH)
print("done")
