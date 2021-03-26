import os
import re
import pywikibot

site = pywikibot.Site('en', 'wowpedia')

def getFileText(p):
	f = open(p)
	lines = f.readlines()
	return "".join(lines)

def replaceElinks(newPath, base):
	apiName = base.replace(".txt", "")
	page = pywikibot.Page(site, apiName)
	wp_seealso = re.findall("==See also==\n\* \[https://www.townlong-yak.com.*", page.text)
	if wp_seealso:
		fileText = getFileText(newPath)
		doc_elinks = re.findall("==External links==\n.*\n.*", fileText)
		page.text = page.text.replace(wp_seealso[0], doc_elinks[0])
		page.save(summary="Update elinks")

def recursiveFiles(path):
	for base in os.listdir(path):
		newPath = path+"/"+base
		if os.path.isdir(newPath):
			recursiveFiles(newPath)
		else:
			replaceElinks(newPath, base)

recursiveFiles("wowpedia/system")

print("done")
