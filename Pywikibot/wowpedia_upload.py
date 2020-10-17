import pywikibot
import os

site = pywikibot.Site('en', 'wowpedia')
PATH = "wowpedia"

def getFileText(p):
	f = open(p)
	lines = f.readlines()
	return "".join(lines)

for line1 in os.listdir(PATH):
	p1 = PATH+"/"+line1
	if os.path.isdir(p1):
		for line2 in os.listdir(p1):
			pageName = line2.replace(".txt", "")
			print("-- reading "+pageName)
			page = pywikibot.Page(site, pageName)
			if not page.text:
				page.text = getFileText(p1+"/"+line2)
				page.save()

print("done")
