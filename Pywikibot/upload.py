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
	text = getFileText(path)
	if not page.exists():
		page.text = text
		page.save(summary="10.0.2 (45779)")
	elif page.text.find("{{api generated}}") > -1:
		userName = page.userName()
		if userName != "Ketho" and userName != "KethoBot":
			print("----- edited by", page.userName(), page.title())
		else:
			page.text = text
			page.save(summary="10.0.2 (45779)")

def recursiveFiles(path):
	for base in os.listdir(path):
		newPath = path+"/"+base
		if os.path.isdir(newPath):
			recursiveFiles(newPath)
		else:
			saveFile(newPath, base)

recursiveFiles(PATH)
print("done")
