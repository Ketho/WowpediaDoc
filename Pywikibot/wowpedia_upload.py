import os
import pywikibot

# im kinda new to python
site = pywikibot.Site('en', 'wowpedia')
PATH = "out/system"

def getFileText(p):
	f = open(p)
	lines = f.readlines()
	return "".join(lines)

for line1 in os.listdir(PATH):
	p1 = PATH+"/"+line1
	if os.path.isdir(p1):
		for line2 in os.listdir(p1):
			pageName = line2.replace(".txt", "")
			page = pywikibot.Page(site, pageName)
			page.text = getFileText(p1+"/"+line2)
			page.save()

print("done")
